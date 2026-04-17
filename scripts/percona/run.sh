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
LOG_FILE="${LOG_DIR}/percona_${MUTATOR_TYPE}_${TIMESTAMP}.txt"
exec > >(tee -a "${LOG_FILE}") 2>&1
echo "Logging to ${LOG_FILE}"

# shellcheck source=../common.sh
source "${SCRIPT_DIR}/../common.sh"

# Strict version from documents/DBMS Version.md: Percona Server 8.0.43-34
IMAGE="percona:8.0.43-34"
CONTAINER="valscope-percona-8-0-43-34"
PREFERRED_PORT=23306
HOST_PORT="$(find_free_port "${PREFERRED_PORT}")"

echo "Pulling ${IMAGE} ..."
docker pull "${IMAGE}" >/dev/null

remove_container_if_exists "${CONTAINER}"

echo "Starting container ${CONTAINER} on host port ${HOST_PORT} ..."
docker run -d --name "${CONTAINER}" \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e MYSQL_DATABASE=test \
  -p "${HOST_PORT}:3306" \
  "${IMAGE}" >/dev/null

wait_mysql_ready "127.0.0.1" "${HOST_PORT}" "root" "123456" "test" 300

invoke_valscope_workflow \
  "${PROJECT_ROOT}" \
  "percona" \
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
