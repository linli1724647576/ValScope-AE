# DBMS Test Version Information

This document records the version information of various Database Management Systems (DBMS) used in the testing of the Valscope project.

## Supported DBMS Versions List

| DBMS | Version | Notes | Github Stars | DB-Engine | First Release|
|------|---------|-------| ------------ | -------- | ------------ |
| TiDB | 8.0.11-TiDB-v7.5.1 | - | 39.4k | 85 | 2016|
| MySQL | 9.4.0 | - | 11.9k | 2 | 1995|
| OceanBase | 5.7.25-OceanBase_CE-v4.3.5.4 | Community Edition | 9.8k | 99 |2010|
| MariaDB | 12.0.2-MariaDB-ubu2404 | Ubuntu 24.04 version | 6.7k | 13 | 2009|
| Percona Server | 8.0.43-34 | - | 1.2k | 122 | 2008|
| PolarDB | 8.0.32-X-Cluster-8.4.19 | X-Cluster version | 1.6k | 105 | 2017|

## Version Selection Notes

- Includes mainstream MySQL ecosystem databases
- Covers both commercial and community editions
- Includes cloud-native databases such as TiDB and PolarDB
- All selected versions are relatively new stable releases

## Version Compatibility Considerations

Different DBMS may have differences in SQL syntax, function implementations, and performance characteristics. These differences may affect the mutation testing results of Pinolo_Extension. When analyzing test results, these version differences should be taken into account.