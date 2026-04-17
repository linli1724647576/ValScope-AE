#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
NUM_QUERIES=1000
TOTAL_INSERT_STATEMENTS=40
RUN_HOURS=24
MUTATOR_TYPE="both"
SKIP_MUTATE=0

usage() {
  cat <<'EOF'
Usage: ./run.sh [options]
  --project-root <path>
  --num-queries <int>
  --total-insert-statements <int>
  --run-hours <int|float>
  --mutator-type <value|set|both>
  --skip-mutate
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root)
      PROJECT_ROOT="$2"; shift 2 ;;
    --num-queries)
      NUM_QUERIES="$2"; shift 2 ;;
    --total-insert-statements)
      TOTAL_INSERT_STATEMENTS="$2"; shift 2 ;;
    --run-hours)
      RUN_HOURS="$2"; shift 2 ;;
    --mutator-type)
      MUTATOR_TYPE="$2"; shift 2 ;;
    --skip-mutate)
      SKIP_MUTATE=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

MUTATOR_TYPE="$(echo "$MUTATOR_TYPE" | tr '[:upper:]' '[:lower:]')"
if [[ "$MUTATOR_TYPE" != "value" && "$MUTATOR_TYPE" != "set" && "$MUTATOR_TYPE" != "both" ]]; then
  echo "--mutator-type must be value, set, or both" >&2
  exit 1
fi

LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "${LOG_DIR}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${LOG_DIR}/oceanbase_${MUTATOR_TYPE}_${TIMESTAMP}.txt"
exec > >(tee -a "${LOG_FILE}") 2>&1
echo "Logging to ${LOG_FILE}"

# shellcheck source=../common.sh
source "${SCRIPT_DIR}/../common.sh"

# Strict version from documents/DBMS Version.md: 5.7.25-OceanBase_CE-v4.3.5.4
# Pullable mapped tag: 4.3.5.4 build tag on Docker Hub
IMAGE="oceanbase/oceanbase-ce:4.3.5.4-104000042025090916"
CONTAINER="valscope-oceanbase-4-3-5-4"
PREFERRED_PORT=2881
HOST_PORT="$(find_free_port "${PREFERRED_PORT}")"

echo "Pulling ${IMAGE} ..."
docker pull "${IMAGE}" >/dev/null

remove_container_if_exists "${CONTAINER}"

echo "Starting container ${CONTAINER} on host port ${HOST_PORT} ..."
docker run -d --name "${CONTAINER}" \
  -e MODE=mini \
  -p "${HOST_PORT}:2881" \
  "${IMAGE}" >/dev/null

OCEANBASE_HOST_PORT="${HOST_PORT}" "${PYTHON_BIN}" - <<'PY'
import os
import time
import pymysql

host = "127.0.0.1"
port = int(os.environ["OCEANBASE_HOST_PORT"])
deadline = time.time() + 900
last_err = None

candidates = [
    ("root@sys", ""),
    ("root@sys", "root"),
    ("root", ""),
    ("root", "123456"),
]

conn = None
while time.time() < deadline and conn is None:
    for user, password in candidates:
        try:
            conn = pymysql.connect(
                host=host,
                port=port,
                user=user,
                password=password,
                database="oceanbase",
                autocommit=True,
                connect_timeout=5,
                charset="utf8mb4",
            )
            break
        except Exception as e:
            last_err = e
    if conn is None:
        time.sleep(3)

if conn is None:
    raise SystemExit(f"OceanBase not ready. Last error: {last_err}")

cur = conn.cursor()
stmts = [
    "CREATE DATABASE IF NOT EXISTS test",
    "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY ''",
    "GRANT ALL PRIVILEGES ON test.* TO 'root'@'%'",
    "FLUSH PRIVILEGES",
]
for s in stmts:
    try:
        cur.execute(s)
    except Exception:
        pass
cur.close()
conn.close()
PY

wait_mysql_ready "127.0.0.1" "${HOST_PORT}" "root" "" "test" 300

invoke_valscope_workflow \
  "${PROJECT_ROOT}" \
  "oceanbase" \
  "127.0.0.1" \
  "${HOST_PORT}" \
  "root" \
  "" \
  "test" \
  "${NUM_QUERIES}" \
  "${TOTAL_INSERT_STATEMENTS}" \
  2 \
  "${RUN_HOURS}" \
  "${MUTATOR_TYPE}" \
  "${SKIP_MUTATE}"
