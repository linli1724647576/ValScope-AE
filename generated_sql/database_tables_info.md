# Database Table Structure Information

## Database Connection Information
- **Host**: 127.0.0.1
- **Port**: 13308
- **Database**: test
- **Dialect**: MYSQL
- **Table Count**: 3

## Table Details

### t1
- **Primary Key**: `c1`

| Column Name | Data Type | Category | Nullable |
|------|---------|------|---------|
| c1 | int | numeric | No |
| c2 | varchar(255) | string | No |
| c3 | varchar(255) | string | Yes |
| c4 | int | numeric | Yes |
| c5 | date | datetime | No |
| c6 | varchar(10) | string | No |

### t2
- **Primary Key**: `c1`

| Column Name | Data Type | Category | Nullable |
|------|---------|------|---------|
| c1 | int | numeric | No |
| c2 | int | numeric | No |
| c3 | decimal(10,2) | numeric | No |
| c4 | varchar(50) | string | No |
| c5 | date | datetime | No |
| c6 | mediumtext | string | Yes |
| c7 | longtext | string | Yes |
| c8 | mediumblob | string | Yes |
| c9 | longblob | string | Yes |
| c10 | enum('value1','value2','value3') | string | Yes |
| c11 | set('a','b','c','d') | string | Yes |
| c12 | bit(8) | string | Yes |
| c13 | datetime | datetime | Yes |
| c14 | float(8,2) | numeric | Yes |
| c15 | double(12,4) | numeric | Yes |

### t3
- **Primary Key**: `c1`

| Column Name | Data Type | Category | Nullable |
|------|---------|------|---------|
| c1 | int | numeric | No |
| c2 | int | numeric | No |
| c3 | int | numeric | No |
| c4 | year | datetime | No |
| c5 | time | datetime | Yes |
| c6 | tinyint | numeric | Yes |
| c7 | smallint | numeric | Yes |
| c8 | mediumint | numeric | Yes |
| c9 | bigint | numeric | Yes |
| c10 | longtext | string | Yes |
| c11 | geometry | string | Yes |
| c12 | tinytext | string | Yes |
| c13 | tinyblob | string | Yes |
| c14 | set('x','y','z') | string | Yes |
| c15 | tinyint(1) | numeric | Yes |

