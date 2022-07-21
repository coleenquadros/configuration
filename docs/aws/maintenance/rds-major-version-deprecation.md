[TOC]

# AWS RDS Major version deprecation

AWS typically deprecates major version soon after upstream deprecates it.

End-of-Life / Support cycles
* [PostgreSQL](https://www.postgresql.org/support/versioning/)
* [MySQL](https://www.mysql.com/support/supportedplatforms/database.html)

# Instructions for major version deprecations

## PostgreSQL 10

The final release of PostgreSQL 10 is scheduled for [November 10, 2022](https://www.postgresql.org/support/versioning/). After this date, PostgreSQL 10 will no longer receive bug or security fixes. Teams running this version should be ready to upgrade the major version of their database at any time after the final release date because any security issues that are discovered won't be patched.

AWS RDS will typically force major version upgrades shortly after the final release of a version of PostgreSQL. For PostgreSQL 9.6, this date was in January (roughly two months after the final release). At the time of this writing, AWS RDS has not yet released the date in which they will force a major version upgrade for databases running PostgreSQL 10.

# FAQ

## How do I know if my database is affected?

Simply check the `engine_version` specified for your database in app-interface.

## Which major version should I upgrade to?

This is a decision that should be made by your team, but keep in mind that each major version that you upgrade will provide year(s) of bug and security fixes, which will result in more time in between major version upgrades. For example, upgrading from PostgreSQL 10.x to 14.x will provide four additional years of bug and security fixes, while upgrading to PostgreSQL 11.x would only provide another year of bug and security fixes.

## Will the upgrade result in a downtime?

Yes, you can typically expect **3-6 hours of downtime**, but there are several factors that can influence this like how many versions are in between the current and target major version, the size of the database, and the existence of read-replicas.

Performing a dry run of the upgrade (on a clone of your production database) can assist in providing a better estimate of downtime for those services that have higher availability requirements.

## What is involved in the upgrade?

AppSRE has documented the process for performing an upgrade [here](/docs/dba/postgresql-rds-instance-major-version-upgrade.md).
