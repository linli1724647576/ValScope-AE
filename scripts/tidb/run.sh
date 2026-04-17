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
LOG_FILE="${LOG_DIR}/tidb_${MUTATOR_TYPE}_${TIMESTAMP}.txt"
exec > >(tee -a "${LOG_FILE}") 2>&1
echo "Logging to ${LOG_FILE}"

# shellcheck source=../common.sh
source "${SCRIPT_DIR}/../common.sh"

# Strict version from documents/DBMS Version.md: TiDB 8.0.11-TiDB-v7.5.1
IMAGE="pingcap/tidb:v7.5.1"
CONTAINER="valscope-tidb-v7-5-1"
PREFERRED_PORT=4000
HOST_PORT="$(find_free_port "${PREFERRED_PORT}")"

echo "Pulling ${IMAGE} ..."
docker pull "${IMAGE}" >/dev/null

remove_container_if_exists "${CONTAINER}"

echo "Starting container ${CONTAINER} on host port ${HOST_PORT} ..."
docker run -d --name "${CONTAINER}" -p "${HOST_PORT}:4000" "${IMAGE}" >/dev/null

wait_mysql_ready "127.0.0.1" "${HOST_PORT}" "root" "" "mysql" 300

TIDB_HOST_PORT="${HOST_PORT}" "${PYTHON_BIN}" - <<'PY'
import os
import pymysql

host = "127.0.0.1"
port = int(os.environ["TIDB_HOST_PORT"])
conn = pymysql.connect(host=host, port=port, user="root", password="", database="mysql", autocommit=True, charset="utf8mb4")
cur = conn.cursor()

stmts = [
    "CREATE DATABASE IF NOT EXISTS test",
    "ALTER USER 'root'@'%' IDENTIFIED BY '123456'",
    "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456'",
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

wait_mysql_ready "127.0.0.1" "${HOST_PORT}" "root" "123456" "test" 300

invoke_valscope_workflow \
  "${PROJECT_ROOT}" \
  "tidb" \
  "127.0.0.1" \
  "${HOST_PORT}" \
  "root" \
  "123456" \
  "test" \
  "${NUM_QUERIES}" \
  "${TOTAL_INSERT_STATEMENTS}" \
  2 \
  "${RUN_HOURS}" \
  "${MUTATOR_TYPE}" \
  "${SKIP_MUTATE}"
