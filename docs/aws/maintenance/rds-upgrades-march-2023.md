# RDS OS Upgrades - March 2023

[TOC]

Amazon RDS for PostgreSQL minor versions 14.2, 14.1, 13.6, 13.5, 13.4, 13.3, 12.10, 12.9, 12.8, 12.7, 11.15, 11.14, 11.13, 11.12, 10.20, 10.19, 10.18 and 10.17 will reach end of standard support on March 20, 2023. To prevent issues we ask the tenants to upgrade their RDS versions. The minimum supported versions by AppSRE are documented [here](/README.md#approved-rds-versions).

Minor version upgrades of database engines are typically backwards-compatible, but teams will need to perform their due diligence and test the impact of the upgrade on their services.

## How do I know if my RDS instances are affected?

[Click here](/README.md#approved-rds-versions) for a list of approved RDS database engine versions.

- If you aren't running an approved minor version of your database engine, then your RDS instance is affected and will need a database engine minor version upgrade.

## What do I need to do if I have an affected RDS instance?

If your RDS instances are not running [approved versions](/README.md#approved-rds-versions), then you will need to [upgrade the database engine minor version in app-interface](/README.md#rds-minor-version-upgrades).

## Will these upgrades cause a downtime?

Yes, you can expect a downtime for upgrades. They will occur during the maintenance window that you've configured for your RDS instance.

The downtime is associated with the database engine minor version upgrade, which you can read more about [here](/README.md#rds-minor-version-upgrades)

## Timeline

The timeline below summarizes the actions that need to be taken by each date.

| Deadline      | Tasks |
| ----------- | ----------- |
| ASAP      | 1. Teams using RDS should check if their databases are running the versions outlined [here](/README.md#approved-rds-versions)<br>2. Start upgrading the minor versions of your affected databases in stage as soon as possible to provide sufficient time for testing       |
| February 20, 2023 00:00:01 AM UTC | You will not be able to create new RDS instances with PostgreSQL minor versions listed above. |
| March 20, 2023 00:00:01 AM UTC | * All stage and production databases should be running [approved versions of the database engine](/README.md#approved-rds-versions).<br>* If you haven't upgraded, AWS will begin upgrading your PostgreSQL databases during the maintenance windows configured in RDS. |
| April 20, 2023 00:00:01 AM UTC | All RDS instances running unsupported PostgreSQL minor versions will be upgraded to the latest minor version outside of your maintenance window.    |
