# RDS High ReplicaLag

## Description

The RDS ReplicaLag metric indicates how far behind a RDS replica instances is from the
primary. This can have implications for some services that rely on the replica data to
be up-to-date, or for disaster recovery where a replica that is severely behind (hours,
or days) could result in data loss if the replica needed to be promoted and the primary
was down.

## Steps

This topic is already well-covered by AWS, so please see the following for troubleshooting:

* [PostgreSQL instances](https://aws.amazon.com/premiumsupport/knowledge-center/rds-postgresql-replication-lag/)
* [MySQL instances](https://aws.amazon.com/premiumsupport/knowledge-center/rds-mysql-high-replica-lag/)
