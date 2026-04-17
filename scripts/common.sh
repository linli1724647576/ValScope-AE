#!/usr/bin/env bash
set -euo pipefail

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "python3/python is required but not found." >&2
  exit 1
fi

remove_container_if_exists() {
  local name="$1"
  if docker ps -a --format '{{.Names}}' | grep -Fxq "$name"; then
    docker rm -f "$name" >/dev/null
  fi
}

find_free_port() {
  local start_port="$1"
  local max_tries="${2:-200}"
  local port="$start_port"
  local try_count=0

  while [[ "$try_count" -lt "$max_tries" ]]; do
    if "$PYTHON_BIN" - "$port" <<'PY'
import socket
import sys

port = int(sys.argv[1])
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
try:
    sock.bind(("127.0.0.1", port))
except OSError:
    raise SystemExit(1)
finally:
    sock.close()
raise SystemExit(0)
PY
    then
      echo "$port"
      return 0
    fi
    port=$((port + 1))
    try_count=$((try_count + 1))
  done

  echo "Failed to find a free port from ${start_port} after ${max_tries} tries." >&2
  return 1
}

wait_mysql_ready() {
  local host="$1"
  local port="$2"
  local user="$3"
  local password="$4"
  local database="$5"
  local timeout_sec="${6:-300}"

  WAIT_HOST="$host" \
  WAIT_PORT="$port" \
  WAIT_USER="$user" \
  WAIT_PASSWORD="$password" \
  WAIT_DATABASE="$database" \
  WAIT_TIMEOUT="$timeout_sec" \
  "$PYTHON_BIN" - <<'PY'
import os
import time
import pymysql

host = os.environ["WAIT_HOST"]
port = int(os.environ["WAIT_PORT"])
user = os.environ["WAIT_USER"]
password = os.environ["WAIT_PASSWORD"]
database = os.environ["WAIT_DATABASE"]
timeout = int(os.environ["WAIT_TIMEOUT"])

start = time.time()
last_err = None
while time.time() - start < timeout:
    try:
        conn = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=database,
            connect_timeout=5,
            charset="utf8mb4",
        )
        conn.close()
        print(f"DB ready at {host}:{port}")
        raise SystemExit(0)
    except Exception as e:
        last_err = e
        time.sleep(2)

raise SystemExit(f"Timeout waiting for DB at {host}:{port}. Last error: {last_err}")
PY
}

invoke_valscope_workflow() {
  local project_root="$1"
  local dialect="$2"
  local db_host="$3"
  local db_port="$4"
  local db_user="$5"
  local db_password="$6"
  local db_name="$7"
  local num_queries="$8"
  local total_insert_statements="$9"
  local subquery_depth="${10}"
  local run_hours="${11}"
  local mutator_type="${12}"
  local skip_mutate="${13}"

  (
    cd "$project_root"
    VALSCOPE_DIALECT="$dialect" \
    VALSCOPE_DB_HOST="$db_host" \
    VALSCOPE_DB_PORT="$db_port" \
    VALSCOPE_DB_USER="$db_user" \
    VALSCOPE_DB_PASSWORD="$db_password" \
    VALSCOPE_DB_NAME="$db_name" \
    VALSCOPE_NUM_QUERIES="$num_queries" \
    VALSCOPE_TOTAL_INSERTS="$total_insert_statements" \
    VALSCOPE_SUBQUERY_DEPTH="$subquery_depth" \
    VALSCOPE_RUN_HOURS="$run_hours" \
    VALSCOPE_MUTATOR_TYPE="$mutator_type" \
    VALSCOPE_SKIP_MUTATE="$skip_mutate" \
    "$PYTHON_BIN" - <<'PY'
import os
import time
import pymysql
from data_structures.db_dialect import set_dialect
from generate_random_sql import Generate
from get_seedQuery import SeedQueryGenerator
from changeAST import MutateSolve

dialect = os.environ["VALSCOPE_DIALECT"]
host = os.environ["VALSCOPE_DB_HOST"]
port = int(os.environ["VALSCOPE_DB_PORT"])
user = os.environ["VALSCOPE_DB_USER"]
password = os.environ["VALSCOPE_DB_PASSWORD"]
db_name = os.environ["VALSCOPE_DB_NAME"]
num_queries = int(os.environ["VALSCOPE_NUM_QUERIES"])
total_inserts = int(os.environ["VALSCOPE_TOTAL_INSERTS"])
subquery_depth = int(os.environ["VALSCOPE_SUBQUERY_DEPTH"])
run_hours = float(os.environ["VALSCOPE_RUN_HOURS"])
mutator_type = os.environ.get("VALSCOPE_MUTATOR_TYPE", "both").lower()
skip_mutate = os.environ.get("VALSCOPE_SKIP_MUTATE", "0") == "1"

if mutator_type in ("both", "value+set", "set+value"):
    mutator_plan = ["value", "set"]
elif mutator_type in ("value", "set"):
    mutator_plan = [mutator_type]
else:
    print(f"Unsupported mutator type '{mutator_type}', fallback to both")
    mutator_plan = ["value", "set"]

print(f"Dialect: {dialect}")
print(f"DB: {host}:{port}, user={user}, db={db_name}")
print(f"Mutator: {mutator_type}")
print(f"Mutator plan: {mutator_plan}")
print(f"Run hours: {run_hours}")

set_dialect(dialect)

def _split_sql_statements(sql_text: str):
    statements = []
    current = []
    in_single = False
    in_double = False
    in_backtick = False
    escape = False

    for ch in sql_text:
        if escape:
            current.append(ch)
            escape = False
            continue

        if ch == "\\":
            current.append(ch)
            if in_single or in_double:
                escape = True
            continue

        if ch == "'" and not in_double and not in_backtick:
            in_single = not in_single
            current.append(ch)
            continue
        if ch == '"' and not in_single and not in_backtick:
            in_double = not in_double
            current.append(ch)
            continue
        if ch == "`" and not in_single and not in_double:
            in_backtick = not in_backtick
            current.append(ch)
            continue

        if ch == ";" and not in_single and not in_double and not in_backtick:
            stmt = "".join(current).strip()
            if stmt:
                statements.append(stmt)
            current = []
            continue

        current.append(ch)

    tail = "".join(current).strip()
    if tail:
        statements.append(tail)
    return statements


def _execute_sql_script(sql_file_path: str):
    with open(sql_file_path, "r", encoding="utf-8") as f:
        sql_text = f.read()

    # Remove full-line comments to avoid dialect comment parsing issues.
    filtered_lines = []
    for line in sql_text.splitlines():
        if line.strip().startswith("--"):
            continue
        filtered_lines.append(line)
    sql_text = "\n".join(filtered_lines)
    statements = _split_sql_statements(sql_text)

    conn = None
    try:
        # Prefer connecting without a default database so DROP/CREATE/USE can run safely.
        conn = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            charset="utf8mb4",
            autocommit=True,
        )
    except Exception:
        conn = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database=db_name,
            charset="utf8mb4",
            autocommit=True,
        )

    def _is_index_statement(stmt: str) -> bool:
        s = stmt.strip().upper()
        return (
            s.startswith("CREATE INDEX")
            or s.startswith("CREATE SPATIAL INDEX")
            or s.startswith("CREATE UNIQUE INDEX")
            or " ADD INDEX " in f" {s} "
            or " ADD KEY " in f" {s} "
            or " ADD UNIQUE KEY " in f" {s} "
            or " ADD SPATIAL INDEX " in f" {s} "
        )

    def _should_ignore_index_error(stmt: str, exc: Exception) -> bool:
        msg = str(exc).lower()
        if not _is_index_statement(stmt):
            # Some index/key definition errors are raised from CREATE/ALTER TABLE
            # statements instead of standalone CREATE INDEX statements.
            if not any(token in msg for token in ("index", "key parts", "duplicate key", "spatial")):
                return False

        # Common MySQL index-definition failures from random bootstrap DDL.
        ignorable_errnos = {
            1061,  # Duplicate key name
            1070,  # Too many key parts specified
            1252,  # All parts of a SPATIAL index must be NOT NULL
            1831,  # Duplicate index / key related failures (version-dependent)
        }

        errno = None
        if hasattr(exc, "args") and exc.args:
            try:
                errno = int(exc.args[0])
            except Exception:
                errno = None

        if errno in ignorable_errnos:
            return True
        if "index" in msg and ("duplicate" in msg or "spatial" in msg or "key parts" in msg):
            return True
        return False

    try:
        with conn.cursor() as cur:
            for stmt in statements:
                try:
                    cur.execute(stmt)
                except Exception as e:
                    if _should_ignore_index_error(stmt, e):
                        print(f"Ignoring index-related SQL error: {e}")
                        continue
                    raise
    finally:
        conn.close()


def _patch_seed_generator_connection():
    def _reset_persistent_connection(self):
        conn = getattr(self, "_persistent_conn", None)
        self._persistent_conn = None
        if conn is not None:
            try:
                conn.close()
            except Exception:
                pass

    def _connect_db(self, max_retries=5, retry_delay=0.2):
        if getattr(self, "_persistent_conn", None) is not None:
            try:
                self._persistent_conn.ping(reconnect=False)
                return self._persistent_conn
            except Exception as e:
                self.last_connect_error = str(e)
                _reset_persistent_connection(self)

        conn_params = {
            "host": host,
            "user": user,
            "password": password,
            "database": db_name,
            "port": port,
            "charset": "utf8mb4",
        }
        max_retries = max(1, int(max_retries))
        for attempt in range(max_retries):
            try:
                conn = pymysql.connect(**conn_params)
                self._persistent_conn = conn
                self.last_connect_error = None
                return conn
            except Exception as e:
                self.last_connect_error = str(e)
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
        return None

    SeedQueryGenerator.connect_db = _connect_db
    SeedQueryGenerator._reset_persistent_connection = _reset_persistent_connection


db_config = {
    "host": host,
    "port": port,
    "database": db_name,
    "user": user,
    "password": password,
    "dialect": "MYSQL",
}

# Bootstrap base schema and DML data before metadata-based generation.
print("Bootstrapping base schema/data from generator ...")
Generate(
    subquery_depth=subquery_depth,
    total_insert_statements=total_inserts,
    num_queries=1,
    query_type="default",
    use_database_tables=False,
)
schema_file = os.path.join("generated_sql", "schema.sql")
_execute_sql_script(schema_file)
print(f"Bootstrap completed using {schema_file}")

# Ensure SeedQueryGenerator and mutation stage use the runtime DB endpoint.
_patch_seed_generator_connection()

cycle_metrics = []
total_success_count = 0
total_query_count = 0
cycle_count = 0

total_seconds = max(run_hours, 0.0) * 3600.0
cycle_start_time = time.time()

while time.time() - cycle_start_time < total_seconds:
    cycle_count += 1
    print("")
    print(f"===== Starting cycle {cycle_count} =====")
    try:
        t0 = time.time()
        Generate(
            subquery_depth=subquery_depth,
            total_insert_statements=total_inserts,
            num_queries=num_queries,
            query_type="default",
            use_database_tables=True,
            db_config=db_config,
        )
        t1 = time.time()
        gen_duration = max(t1 - t0, 1e-9)
        gen_rate = num_queries / gen_duration

        seed = SeedQueryGenerator()
        total_queries = seed.get_queries_count()
        seed.get_seedQuery()

        seed_file_path = os.path.join("generated_sql", "seedQuery.sql")
        success_count = 0
        if os.path.exists(seed_file_path):
            with open(seed_file_path, "r", encoding="utf-8") as f:
                for line in f:
                    sql = line.strip()
                    if not sql:
                        continue
                    if sql.startswith("--"):
                        continue
                    if sql.upper().startswith("USE "):
                        continue
                    success_count += 1

        exec_success_rate = (success_count / total_queries * 100.0) if total_queries else 0.0
        total_success_count += success_count
        total_query_count += total_queries
        cycle_metrics.append((gen_rate, exec_success_rate, success_count, total_queries))

        elapsed_seconds = time.time() - cycle_start_time
        remaining_seconds = max(total_seconds - elapsed_seconds, 0.0)
        print(f"Cycle {cycle_count} generation rate: {gen_rate:.2f} queries/s")
        print(f"Cycle {cycle_count} execution success rate: {exec_success_rate:.2f}% ({success_count}/{total_queries})")
        print(f"Cycle {cycle_count} elapsed: {elapsed_seconds:.2f}s, remaining: {remaining_seconds:.2f}s")

        if not skip_mutate:
            for current_mutator in mutator_plan:
                try:
                    print(f"Running mutator: {current_mutator}")
                    extension = (current_mutator == "value")
                    mutator = MutateSolve(extension=extension)
                    mutator.mutate_main()
                except Exception as e:
                    print(f"Mutator '{current_mutator}' failed: {e}")
    except Exception as e:
        print(f"Cycle {cycle_count} failed: {e}")
        continue

print("")
print("==== Final Metrics ====")
print(f"Requested run hours: {run_hours}")
print(f"Completed cycles: {len(cycle_metrics)}")

if cycle_metrics:
    avg_gen_rate = sum(item[0] for item in cycle_metrics) / len(cycle_metrics)
    overall_exec_success_rate = (total_success_count / total_query_count * 100.0) if total_query_count else 0.0
    print(f"Average generation rate: {avg_gen_rate:.2f} queries/s")
    print(f"Overall execution success rate: {overall_exec_success_rate:.2f}% ({total_success_count}/{total_query_count})")
else:
    print("No successful cycles completed.")
PY
  )
}
