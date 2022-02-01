# Amazon Relational Database Service (RDS)

[TOC]

## Overview

[Relational Database Service (RDS)](https://aws.amazon.com/rds/) is a managed database offering from AWS. A number of AppSRE customers use this service to avoid the operations associated with managing your own database (backups, patching, high availability, etc.)

## SOPs

### Database Engine Upgrades

These SOPs cover database major and minor engine upgrades:

* [PostgreSQL major version upgrade](/docs/dba/postgresql-rds-instance-major-version-upgrade.md)
* [PostgreSQL minor version upgrade](/docs/aws/sop/postgresql-rds-instance-minor-version-upgrade.md)

### OS Upgrade

See [this doc](/docs/aws/sop/rds-os-upgrade.md) for applying mandatory OS upgrades in RDS, typically associated with security updates. 

## Troubleshooting

### General Resources

* [Connecting to database](/docs/dba/connect-to-postgres-mysql-database.md)
* [PostgreSQL handy queries](/docs/dba/Postgres-handy-queries.md)
* [MySQL handy queries](/docs/dba/MySQL-handy-queries.md)

### RDS Documentation

* [RDS Out of Storage (STORAGE_FULL)](https://aws.amazon.com/premiumsupport/knowledge-center/rds-out-of-storage/)

## Known issues

### High write latency without depleted burst balance

**Observations**

- High write latency (could be up to 100+ ms)
- Burst balance is not depleted (>0%)

**Summary**

Burst balance can be depleted on a single volume, or even on the Multi-AZ instance, without the burst balance metric reporting 0%.

**What to do**

If RDS events indicate burst balance is depleted:

- Open a [support ticket](#support) with AWS to investigate whether there is an issue with a specific volume, or possibly the Multi-AZ instance
- Work with the application team to find out why the write operations are happening at a higher rate than expected. Is there a background job that could be causing this? Can that job be stopped?
- Look at the baseline performance to figure out if it is regularly being exceeded, in which case the storage may need to be upgraded (IOPS baseline performance is based on storage capacity).

**Explanation**

The write latency metric in RDS is associated with the average time it takes to perform disk I/O operations. This is often elevated when the IOPS that are provisioned for the database are insufficient. If this is the case, you'll often see an elevated disk queue depth too (rough rule of thumb is >1 queue length for every 1000 IOPS).

AppSRE tenants commonly use `gp2` storage, which has a burst balance (see [short blog post](https://aws.amazon.com/es/blogs/database/understanding-burst-vs-baseline-performance-with-amazon-rds-and-gp2/) or [longer docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#CHAP_Storage.IO.Credits) for more info). There is an associated metric that indicates what percentage of the burst balance is available. This typically hovers around 100% if the storage has been provisioned properly.

During one outage, [APPSRE-4027](https://issues.redhat.com/browse/APPSRE-4027), the write latency metric increased 7-8x (over 100ms) **despite burst balance never dropping below 96% burst balance availability**. AWS support indicated that in this case the burst balance was depleted on a single volume on the multi-az instance. This is worth noting because if we relied on burst balance metrics alone, it would seem that it wasn't a burst balance issue.

What we can do in this scenario is check the recent events on the database. See the screenshot below:

![RDS console events](img/burst-balance-events.png "RDS Burst Balance Events")

**More information**

At the time that this entry is being added, we haven't heard back from AWS with respect to the root cause of this issue. See the information below for follow-up.

Internal ticket: [APPSRE-4036](https://issues.redhat.com/browse/APPSRE-4036) \
Account: insights-prod\
Case id: 9183343311

### Errors when applying storage updates

When a tenant increases the size of their RDS storage, an error similar to what is seen below might appear:

```
[terraform-resources-wrapper] [some-aws-account - apply] Error: Error modifying DB Instance some-database: InvalidParameterCombination: Invalid max storage size for engine name postgres and storage type gp2: 6500
```

This is a fairly vague error, but there are a couple things that you can check:

1. Changes to `allocated_storage` or `max_allocated_storage` [must be >= 10% larger](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html#USER_PIOPS.Autoscaling) than the current `allocated_storage` as reported by the AWS API. The `allocated_storage` can grow over time, so the value in app-interface may be out-of-date, which is why you must check the value returned by the AWS API. Alternatively, you may increase the value by 10% of `max_allocated_storage` because that value should always be greater than (or equal to) `allocated_storage`.
2. Ensure that you have not hit the limits of storage volume sizes in RDS. There are some notable exceptions that have lower limits, usually previous generation instances. See the "DB instance class" section of [this document](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Storage.html#Concepts.Storage.GeneralSSD).

## Support

Support tickets can be opened in the AWS support console of the account that the RDS instance is deployed in.
