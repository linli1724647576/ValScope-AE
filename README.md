# Valscope

**Paper.**  This artifact accompanies the OSDI '26 paper: Li Lin, Liehang Chen, and Rongxin Wu, "ValScope: Value-Semantics-Aware Metamorphic Testing for Detecting Logical Bugs in DBMSs." USENIX Symposium on Operating Systems Design and Implementation (OSDI '26), 2026.

```
@inproceedings{lin:valscope,
  title        = {{ValScope: Value-Semantics-Aware Metamorphic Testing for Detecting Logical Bugs in DBMSs.}},
  author       = {Li Lin, Liehang Chen, and Rongxin Wu},
  booktitle    = {Proceedings of the 20th USENIX Symposium on Operating Systems Design and Implementation (OSDI)},
  year         = {2026},
}
```

ValScope is a DBMS testing framework based on a unified SQL query approximation model that combines set-semantic and value-semantic reasoning. By generating, mutating, and verifying SQL queries, it effectively detects logical bugs in DBMSs. It supports multiple database dialects including MySQL, MariaDB, Percona, OceanBase, TiDB, and PolarDB.

Up to now, we have found 67 logical bugs in MySQL, MariaDB, OceanBase, PERCONA, PolarDB, and TiDB,  57 of which have been confirmed by developers.

## MySQL

| ID   | Issue ID                                           | Status    |
| ---- | -------------------------------------------------- | --------- |
| 1    | [118846](https://bugs.mysql.com/bug.php?id=118846) | comfirmed |
| 2    | [119022](https://bugs.mysql.com/bug.php?id=119022) | comfirmed |
| 3    | [119348](https://bugs.mysql.com/bug.php?id=119348) | comfirmed |
| 4    | [119321](https://bugs.mysql.com/bug.php?id=119321) | comfirmed |
| 5    | [119322](https://bugs.mysql.com/bug.php?id=119322) | comfirmed |
| 6    | [119323](https://bugs.mysql.com/bug.php?id=119323) | comfirmed |
| 7    | [119329](https://bugs.mysql.com/bug.php?id=119329) | comfirmed |
| 8    | [119342](https://bugs.mysql.com/bug.php?id=119342) | comfirmed |
| 9    | [119344](https://bugs.mysql.com/bug.php?id=119344) | comfirmed |
| 10   | [119350](https://bugs.mysql.com/bug.php?id=119350) | comfirmed |
| 11   | [119446](https://bugs.mysql.com/bug.php?id=119446) | comfirmed |
| 12   | [119352](https://bugs.mysql.com/bug.php?id=119352) | comfirmed |
| 13   | [119353](https://bugs.mysql.com/bug.php?id=119353) | comfirmed |
| 14   | [119398](https://bugs.mysql.com/bug.php?id=119398) | comfirmed |
| 15   | [119399](https://bugs.mysql.com/bug.php?id=119399) | comfirmed |
| 16   | [119400](https://bugs.mysql.com/bug.php?id=119400) | comfirmed |
| 17   | [119402](https://bugs.mysql.com/bug.php?id=119402) | comfirmed |
| 18   | [119403](https://bugs.mysql.com/bug.php?id=119403) | comfirmed |
| 19   | [119693](https://bugs.mysql.com/bug.php?id=119693) | comfirmed |
| 20   | [119694](https://bugs.mysql.com/bug.php?id=119694) | comfirmed |
| 21   | [119695](https://bugs.mysql.com/bug.php?id=119695) | comfirmed |
| 22   | [119696](https://bugs.mysql.com/bug.php?id=119696) | comfirmed |
| 23   | [119698](https://bugs.mysql.com/bug.php?id=119698) | comfirmed |

## MariaDB

| ID   | Issue ID                                            | Status    |
| ---- | --------------------------------------------------- | --------- |
| 1    | [33026](https://jira.mariadb.org/browse/MDEV-33026) | comfirmed |
| 2    | [33027](https://jira.mariadb.org/browse/MDEV-33027) | comfirmed |
| 3    | [37888](https://jira.mariadb.org/browse/MDEV-37888) | comfirmed |
| 4    | [37891](https://jira.mariadb.org/browse/MDEV-37891) | comfirmed |
| 5    | [38032](https://jira.mariadb.org/browse/MDEV-38032) | comfirmed |
| 6    | [38052](https://jira.mariadb.org/browse/MDEV-38052) | comfirmed |
| 7    | [38063](https://jira.mariadb.org/browse/MDEV-38063) | comfirmed |
| 8    | [38064](https://jira.mariadb.org/browse/MDEV-38064) | comfirmed |
| 9    | [38102](https://jira.mariadb.org/browse/MDEV-38102) | comfirmed |
| 10   | [38247](https://jira.mariadb.org/browse/MDEV-38247) | comfirmed |

## OceanBase

| ID   | Issue ID                                                   | Status    |
| ---- | ---------------------------------------------------------- | --------- |
| 1    | [1752](https://github.com/oceanbase/oceanbase/issues/1752) | comfirmed |
| 2    | [1753](https://github.com/oceanbase/oceanbase/issues/1753) | comfirmed |
| 3    | [1755](https://github.com/oceanbase/oceanbase/issues/1755) | comfirmed |
| 4    | [2326](https://github.com/oceanbase/oceanbase/issues/2326) | comfirmed |
| 5    | [2339](https://github.com/oceanbase/oceanbase/issues/2339) | comfirmed |
| 6    | [2341](https://github.com/oceanbase/oceanbase/issues/2341) | comfirmed |
| 7    | [2340](https://github.com/oceanbase/oceanbase/issues/2340) | pending |

## PERCONA

| ID   | Issue ID                                                  | Status    |
| ---- | --------------------------------------------------------- | --------- |
| 1    | [10277](https://perconadev.atlassian.net/browse/PS-10277) | comfirmed |
| 2    | [10297](https://perconadev.atlassian.net/browse/PS-10297) | comfirmed |
| 3    | [10298](https://perconadev.atlassian.net/browse/PS-10298) | comfirmed |
| 4    | [10299](https://perconadev.atlassian.net/browse/PS-10299) | comfirmed |
| 5    | [10301](https://perconadev.atlassian.net/browse/PS-10301) | comfirmed |
| 6    | [10302](https://perconadev.atlassian.net/browse/PS-10302) | comfirmed |
| 7    | [10303](https://perconadev.atlassian.net/browse/PS-10303) | comfirmed |
| 8    | [10304](https://perconadev.atlassian.net/browse/PS-10304) | comfirmed |
| 9    | [10305](https://perconadev.atlassian.net/browse/PS-10305) | comfirmed |
| 10   | [10252](https://perconadev.atlassian.net/browse/PS-10252) | comfirmed |

## PolarDB

| ID   | Issue ID                                                  | Status    |
| ---- | --------------------------------------------------------- | --------- |
| 1    | [243](https://github.com/polardb/polardbx-sql/issues/243) | comfirmed |
| 2    | [246](https://github.com/polardb/polardbx-sql/issues/246) | comfirmed |
| 3    | [247](https://github.com/polardb/polardbx-sql/issues/247) | comfirmed |
| 4    | [248](https://github.com/polardb/polardbx-sql/issues/248) | comfirmed |
| 5    | [249](https://github.com/polardb/polardbx-sql/issues/249) | pending   |
| 6    | [250](https://github.com/polardb/polardbx-sql/issues/250) | pending   |
| 7    | [251](https://github.com/polardb/polardbx-sql/issues/251) | pending   |
| 8    | [252](https://github.com/polardb/polardbx-sql/issues/252) | pending   |
| 9    | [253](https://github.com/polardb/polardbx-sql/issues/253) | pending   |
| 10   | [254](https://github.com/polardb/polardbx-sql/issues/254) | comfirmed |
| 11   | [255](https://github.com/polardb/polardbx-sql/issues/255) | comfirmed |
| 12   | [256](https://github.com/polardb/polardbx-sql/issues/256) | comfirmed |

## TIDB

| ID   | Issue ID                                              | Status    |
| ---- | ----------------------------------------------------- | --------- |
| 1    | [63643](https://github.com/pingcap/tidb/issues/63643) | confirmed |
| 2    | [64445](https://github.com/pingcap/tidb/issues/64445) | pending   |
| 3    | [64451](https://github.com/pingcap/tidb/issues/64451) | pending   |
| 4    | [64453](https://github.com/pingcap/tidb/issues/64452) | pending   |
| 5    | [64454](https://github.com/pingcap/tidb/issues/64654) | pending   |

## How to Run

### 1. Environment Requirements
- Python 3.8+
- Optional database systems:
  - MySQL 8.0+ (Default port: 13306)
  - MariaDB (Default port: 9901)
  - OceanBase (Default port: 2881)
  - Percona (Default port: 23306)
  - PolarDB (Default port: 8527)

### DBMS Connection Parameter Configuration Locations

DBMS connection parameters in the project follow this priority order:

1. **Direct parameter passing (highest priority)**: Passing `db_config` parameter directly when calling relevant classes
2. **Default configuration in `get_seedQuery.py`**: Default values set during initialization of the `SeedQueryGenerator` class
3. **Dialect-specific configuration in `get_seedQuery.py`**: Specific parameters set for each database in the `connect_db` method

Specific configuration locations:

- **Main configuration file**: `get_seedQuery.py`
  - Lines 8-17: Default database configuration applicable to all database systems
  - Lines 55-110: Specific configurations for each database system, including port numbers and credentials

- **Command line parameters**: In `main.py`
  - Lines 72-78: Database connection parameters passed when calling the `Generate` class
  - Line 82: Creating `SeedQueryGenerator` instance (uses default values when db_config is not explicitly passed)

- **Database dialect configuration**: `data_structures/db_dialect.py`
  - Defines various database dialect classes and related functionality, but does not contain connection parameter configurations

### 2. Install Dependencies
First, ensure all necessary dependency libraries are installed. The project includes a requirements.txt file, which you can use to install all dependencies:

```bash
pip install -r requirements.txt
```

Main dependencies include:
- sqlglot>=18.0.0: Used for SQL parsing and transformation
- pymysql>=1.1.0: Used for MySQL database connections
- psycopg2-binary>=2.9.9: Used for PostgreSQL database connections

### 3. Running Parameter Configuration
In the main.py file, you can configure the following key parameters:

```python
# Database dialect settings (mysql, tidb, mariadb, oceanbase, percona, etc.)
dialect_str = 'mysql'
# Whether to use value mutator extended functionality
use_value_mutator = True
# Runtime duration (hours)
run_hours = 20
# Whether to use real database table structures (False means using simulated table structures)
is_use_database_tables = False
```

### 4. Database Configuration
If `is_use_database_tables=True` is set, you need to configure database connection information to obtain the actual table structure:

```python
db_config={
    'host': '127.0.0.1',      # Database host address
    'port': 4000,             # Database port
    'database': 'test',       # Database name
    'user': 'root',           # Database username
    'password': '123456',     # Database password
}
```

### 5. SQL Generation Configuration
When calling the Generate function, you can configure the following parameters to adjust the characteristics of the generated SQL:

```python
Generate(
    subquery_depth=2,           # Subquery depth, default is 1
    total_insert_statements=40, # Total number of INSERT statements to generate
    num_queries=1000,           # Number of query statements to generate
    query_type='default',       # Query type
    use_database_tables=is_use_database_tables,
    db_config=db_config
)
```

### 6. Execution Command

```bash
python main.py
```

### 7. Output Description
- **generated_sql/** directory:
  - `queries.sql` - Generated random SQL queries
  - `seedQuery.sql` - Seed queries for mutation
  - `schema.sql` - Simulated or real table structure definitions
  - `indexes.sql` - Index definitions

- **logs/** directory:
  - Execution log files, containing timestamps, execution time, error messages, etc.

- **invalid_mutation/** directory:
  - Stores invalid mutation results categorized by database type

## Artifact Evaluation

This section describes how to evaluate **ValScope** using the scripts in this repository.

ValScope performs SQL generation, seed-query extraction, and mutation-based checking under set/value semantics. The evaluation is time-based (same as `main.py` logic), and each run writes full logs to `logs/`.

### Supported DBMS and Scripts

ValScope currently provides automated scripts for:

- MySQL: `scripts/mysql/run.sh`
- MariaDB: `scripts/mariadb/run.sh`
- Percona: `scripts/percona/run.sh`
- TiDB: `scripts/tidb/run.sh`
- OceanBase: `scripts/oceanbase/run.sh`
- PolarDB: `scripts/polardb/run.sh`

Each dialect also provides:

- `run_valuemutator.sh` (equivalent to `--mutator-type value`)
- `run_setmutator.sh` (equivalent to `--mutator-type set`)

### How to Run

Run one campaign (default 24 hours):

```bash
bash scripts/<dialect>/run.sh
```

`<dialect>` can be one of:

- `mysql`
- `mariadb`
- `percona`
- `tidb`
- `oceanbase`
- `polardb`

By default, `run.sh` uses `--mutator-type both` (runs `value` and `set` in sequence).

Run a short campaign with explicit mutator:

```bash
bash scripts/mysql/run.sh --mutator-type set --run-hours 0.5
bash scripts/tidb/run.sh --mutator-type value --run-hours 0.5
```

Or use wrappers (available under every dialect directory):

```bash
bash scripts/mysql/run_setmutator.sh --run-hours 0.5
bash scripts/mysql/run_valuemutator.sh --run-hours 0.5
bash scripts/mariadb/run_setmutator.sh --run-hours 0.5
```

Common options:

- `--num-queries <int>`
- `--total-insert-statements <int>`
- `--run-hours <int|float>`
- `--mutator-type <value|set|both>`
- `--skip-mutate`

Note: `--rounds` and `--max-mutate-queries` are not supported in dialect scripts.

### Reproducibility Notes

- SQL generation is randomized, so query text can differ across runs.
- For fair comparison, keep runtime budget (`--run-hours`), mutator type, and DBMS version consistent.
- Dialect script comments and image tags document the tested DBMS versions.

### Recorded Outputs and Bug Artifacts

ValScope records artifacts in the following locations:

- `logs/`: per-run execution logs (for example `mysql_value_YYYYMMDD_HHMMSS.txt`)
- `generated_sql/`:
  - `schema.sql` (bootstrap schema/data SQL)
  - `queries.sql` (generated random SQL)
  - `seedQuery.sql` (executable seed queries used for mutation)
- `invalid_mutation/<DIALECT>/`:
  - `ValueMutator_<DIALECT>_invalid_mutations.log`
  - `SetMutator_<DIALECT>_invalid_mutations.log`

### How to Interpret a Potential Bug

- **Logic bug candidate**: mutation mismatch records where transformed and original queries violate the expected semantic relation.
- **Non-logic bug candidate**: DBMS internal errors, crashes, or abnormal execution failures captured in run logs.

When reporting a bug, include:

- DBMS version and script used
- setup SQL (`generated_sql/schema.sql`)
- original/mutated SQL pair from logs
- result mismatch or error evidence from `logs/` and `invalid_mutation/`
