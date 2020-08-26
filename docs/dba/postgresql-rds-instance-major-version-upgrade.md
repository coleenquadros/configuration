# Upgrade Major Version for PostgreSQL RDS Instance

- [Upgrade Major Version for PostgreSQL RDS Instance](#upgrade-major-version-for-postgresql-rds-instance)
  - [Major Version Upgrade vs. Minor Version Upgrade](#major-version-upgrade-vs-minor-version-upgrade)
  - [AWS Documentation](#aws-documentation)
  - [Steps for Upgrade at High Level](#steps-for-upgrade-at-high-level)
  - [Note About Upgrading Read-Replicas](#note-about-upgrading-read-replicas)
  - [app-interface changes for upgrading](#app-interface-changes-for-upgrading)
    - [MR #01 - Terminate Read Replicas](#mr-01---terminate-read-replicas)
    - [MR #02 - Create a New Parameter Group](#mr-02---create-a-new-parameter-group)
    - [MR #03 - Update RDS Maintenance Window](#mr-03---update-rds-maintenance-window)
    - [MR #04 - Scale DOWN the application](#mr-04---scale-down-the-application)
    - [MR #05 - Update Engine Version](#mr-05---update-engine-version)
    - [MR #06 - Scale UP the application](#mr-06---scale-up-the-application)
    - [MR #07 - Create read-replicas](#mr-07---create-read-replicas)
    - [MR #08 - Update Application Config Changes to use read replicas](#mr-08---update-application-config-changes-to-use-read-replicas)

This document outline the steps and expectations for a major version upgrade of PostgreSQL RDS instance.

## Major Version Upgrade vs. Minor Version Upgrade

There are two kinds of upgrades: major version upgrades and minor version upgrades. In general, a _major engine version upgrade_ can introduce changes that are not compatible with existing applications. In contrast, a _minor version upgrade_ includes only changes that are backward-compatible with existing applications.

## AWS Documentation

Following documentations are _must_ read for anyone considering a _major engine version upgrade_.

- [Upgrading the PostgreSQL DB Engine for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html)
- [Best practices for upgrading Amazon RDS to major and minor versions of PostgreSQL](https://aws.amazon.com/blogs/database/best-practices-for-upgrading-amazon-rds-to-major-and-minor-versions-of-postgresql/)

## Steps for Upgrade at High Level

1. Upgrade will take `3-6` hours and will require someone from AppSRE to be available.
2. Confirm the upgrade path. Upgrading a `10.x` to `12.x` may look something like `10.10 => 11.8 => 12.3`.
3. Identify time window that works for dev team and SRE to upgrade in staging environment.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
4. Write Step by step instructions from developers for stopping the service before upgrade and starting the service after upgrade. If we do not want to stop the service during the upgrade time, we will need dev teams to monitor the service during upgrade process and document the expected behavior.
5. Assuming upgrades goes fine in staging, reach out to stakeholders and get approval to upgrade in production.
   1. **RDS upgrade will result in downtime for your application. Plan for 6 hour outage for the upgrade.**
   2. Upgrades should be started early in the morning. AppSRE will not approve upgrades that start after 11am ET.
6. Identify date and time for production upgrade.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
7. Post necessary banners on Pendo and Statuspage.
8. Execute the upgrade in production.

## Note About Upgrading Read-Replicas

Upgrading RDS instances that have read-replicas is bit more complicated for PostgreSQL. AWS recommends that you **delete and recreate read-replicas after the source instance has upgraded to a different major version.**

## app-interface changes for upgrading

Make changes in following order.

###  MR #01 - Terminate Read Replicas

1. Deploy configuration changes so that your application will stop using read replica instance.
2. Update your parameter group to remove any parameters related to replication.
3. Raise MR to app-interface to delete the read-replica instance. This step will have to executed by AppSRE team member. Remember to set `deletion_protection` to `false` for the read replica instance.
4. Drop the `Logical replication slots`. This step will have to executed by AppSRE team member. If the database is using logical replication slots, the major version upgrade fails and shows the message `PreUpgrade checks failed: The instance could not be upgraded because one or more databases have logical replication slots. Please drop all logical replication slots and try again`. To resolve the issue, stop any running DMS or logical replication jobs and drop any existing replication slots. See the following code:
   ```
    SELECT * FROM pg_replication_slots;
    SELECT pg_drop_replication_slot(slot_name);
    ```

### MR #02 - Create a New Parameter Group

Create a copy of your current parameter group and update at least following 2 things:

1. `family` : The family of the DB parameter group.
2. `name` : The name of the DB parameter group. Must be unique.

At this point the file exists but is not referenced by your RDS instance. This change can be combined with next step.

### MR #03 - Update RDS Maintenance Window

Raise an MR to change the maintenance window to match the time when the upgrade should happen. Usually 15-20 minutes from when you are working on raising the MR. The maintenance window should be `30 minutes`.

### MR #04 - Scale DOWN the application

Set the deployment's replica count to 0.

### MR #05 - Update Engine Version

Update the engine version for your RDS instance in either the defaults file or add it to overriding section. Update parameter group reference to use the file. The actual upgrade step will have to executed by AppSRE team member.

### MR #06 - Scale UP the application

Scale the application back to usual capacity. At this point your application will still not use read-replica as none exists.

### MR #07 - Create read-replicas

Now re-create the read-replica instances.

### MR #08 - Update Application Config Changes to use read replicas

Update your application configuration to use the read replicas.
