# Vertical scaling of RDS instances via app-interface

## Background

From time to time we will need to vertically scale an RDS instance.

A vertical scale is the approach to increase the capacity of a single instance, for example by adding more processing power or storage.

## Purpose

This document explains how to vertically scale an RDS instance managed through app-interface.

## Notes

* Storage: DB storage scale ups are seamless in most cases and will not cause an outage or performance degradation. This is documented here: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html

* Before scaling storage in DB in app-interface, it is important to understand that the storage size cannot be decreased later. Once it is scaled there is no way back. Scaling storage should be coordinated with the instance owner team!

## Process

1. Find the RDS instance you want to scale in the appropriate namespace file.
    * Example - RDS instance defition: [uhc-production/cluster-service](/data/services/ocm/namespaces/uhc-production.yml#L56)
2. Take a snapshot of the RDS instance
    * Find the actual RDS instance in AWS [RDS console](https://console.aws.amazon.com/rds/home?region=us-east-1#databases:)
    * Select the instance and select `Actions` -> `Take snapshot`.
    * The snapshot name should be of the form `<instance-identifier>-<YYYYMMDDHHmmZzzz>`.  Z000 = UTC, Z700 = UTC+7, etc.
        * Example: `clusters-service-production-201906241126Z000`.
3. Add an `overrides` section if one does not exist. Each attribute in this section will override the defaults in the file specified in the `defaults` section.
    * Example - defaults file: [app-sre/production/rds defaults](/resources/terraform/resources/app-sre/production/rds-1.yml)
4. To vertically scale, you can change one of the following attributes under `overrides`:
    * `instance_class` - select a supported instance class.
    > Note: instance class selection is limited in [app-interface schema](https://github.com/app-sre/qontract-schemas/blob/7780755424781d8b88839d2c37e32ccb45fc52da/schemas/openshift/terraform-resource-1.yml#L198-L221).
    * `allocated_storage` - increase allocated storage for the instance.
5. Create a Merge Request to app-interface with these changes.
6. Verify in the `terraform-resources` integration output that the change that is about to happen is of type `update` and not `replace`.
7. A modification (but not maintenance) event will be present for a class change. This change will incur some downtime, which varies by the size and load of the database. To trigger the change, use the aws cli as such:  
```
aws rds modify-db-instance --db-instance-identifier="uhc-acct-mngr-integration" --apply-immediately
```  

This will then put the database into a modifying state and bring it back on-line with the new class.

## Identifying potential issue sources

### Data

Connect to the database server and query the database size e.g.,:

```
postgres=> SELECT pg_size_pretty( pg_database_size('postgres') );
 pg_size_pretty 
----------------
 36 MB
(1 row)
```

There could be other databases to consider querying. To list all available databases:

```
postgres=> \l
```

Note: The commands only work when not being connected to a specific database yet inside the database server.

### Logs

Check the Logs & Events Tab in the RDS instance dashboard. You will see the log sizes there.
Error and slow query logs are accounted to storage space. I.e. it is possible to see relatively
empty databases which still consume a lot of storage space due to logs.

Note, that there is no way to delete logs. By default logs have a 3 day retention period.
Changing the retention period will only affect new logs. It will not have any effect on
already existing logs.


## References

* [AWS Database blog - Scaling Your Amazon RDS Instance Vertically and Horizontally](https://aws.amazon.com/blogs/database/scaling-your-amazon-rds-instance-vertically-and-horizontally/)
* [AWS Documentation - Choosing the DB Instance Class - Supported DB Engines for All Available DB Instance Classes](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Support)
* [RDS tackling diskfull error](https://aws.amazon.com/premiumsupport/knowledge-center/diskfull-error-rds-postgresql/)
