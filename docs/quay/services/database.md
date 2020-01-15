# Quay.io database

The Quay.io database is an [Amazon RDS](https://aws.amazon.com/rds/) instance deployed in US-East-1 with ID `quayenc-2019-quayvpc`.
It is deployed in master-slave configuration, with automatic failover.

## RDS console

The RDS console can be found at [https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc](https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc)


## Encountered Issues

- [Unusually high CPU usage on database](../issues/high-database-cpu.md)
