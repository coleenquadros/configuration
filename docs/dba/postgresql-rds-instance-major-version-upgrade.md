# Upgrade Major Version for PostgreSQL RDS Instance

- [Upgrade Major Version for PostgreSQL RDS Instance](#upgrade-major-version-for-postgresql-rds-instance)
  - [Major Version Upgrade vs. Minor Version Upgrade](#major-version-upgrade-vs-minor-version-upgrade)
  - [AWS Documentation](#aws-documentation)
  - [Steps for Upgrade at High Level](#steps-for-upgrade-at-high-level)
  - [Note About Upgrading Read-Replicas](#note-about-upgrading-read-replicas)
  - [app-interface changes for upgrading](#app-interface-changes-for-upgrading)
    - [Terminate Read Replicas](#terminate-read-replicas)
      - [Remove Read Replica Dependency](#remove-read-replica-dependency)
      - [Read Replicas Termination and Config Updates](#read-replicas-termination-and-config-updates)
    - [Create a New Parameter Group and Update Engine Version](#create-a-new-parameter-group-and-update-engine-version)
    - [Scale DOWN the application](#scale-down-the-application)
    - [Start Database Upgrade](#start-database-upgrade)
      - [Disable Terraform Resources (tf-r) integration in Production using Unleash](#disable-terraform-resources-tf-r-integration-in-production-using-unleash)
      - [Run Terraform Resources (tf-r) integration](#run-terraform-resources-tf-r-integration)
      - [Apply RDS Modifications](#apply-rds-modifications)
    - [Enable Terraform Resources (tf-r) integration in Production using Unleash](#enable-terraform-resources-tf-r-integration-in-production-using-unleash)
    - [Scale UP the application](#scale-up-the-application)
    - [Create read-replicas](#create-read-replicas)
    - [Update Application Config Changes to use read replicas](#update-application-config-changes-to-use-read-replicas)

This document outline the steps and expectations for a major version upgrade of PostgreSQL RDS instance.

## Major Version Upgrade vs. Minor Version Upgrade

There are two kinds of upgrades: major version upgrades and minor version upgrades. In general, a _major engine version upgrade_ can introduce changes that are not compatible with existing applications. In contrast, a _minor version upgrade_ includes only changes that are backward-compatible with existing applications.

## AWS Documentation

Following documentations are _must_ read for anyone considering a _major engine version upgrade_.

- [Upgrading the PostgreSQL DB Engine for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html)
- [Best practices for upgrading Amazon RDS to major and minor versions of PostgreSQL](https://aws.amazon.com/blogs/database/best-practices-for-upgrading-amazon-rds-to-major-and-minor-versions-of-postgresql/)

## Steps for Upgrade at High Level

---

**Teams should not attempt this process without working closely with AppSRE. This is not a self-service process.**

---

This section provides helpful information and an overview of the steps that your team will need to perform to a PostgreSQL major version upgrade.

1. The upgrade duration is based on how large your database is and other factors like whether you have read-replicas. For those services with high availability requirements, a dry-run upgrade may be best to get a better estimate of how long the upgrade will take.
   * You should be prepared for the upgrade to take up to **6 hours**. Someone from AppSRE team will need to be available for the duration of the upgrade.
2. Confirm the upgrade path using the [AWS docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.PostgreSQL.html#USER_UpgradeDBInstance.PostgreSQL.MajorVersion). Note that you may need to upgrade the minor version of your database engine for a major version upgrade to be available.
3. Identify a time window that works for the development team and AppSRE to upgrade the stage database.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
4. Write step-by-step instructions from developers for stopping the service before upgrade and starting the service after upgrade. If we do not want to stop the service during the upgrade time, we will need dev teams to monitor the service during upgrade process and document the expected behavior.
5. After successfully upgrading your stage database, reach out to stakeholders and get approval to upgrade production.
   1. **RDS upgrade will result in downtime for your application. Plan for 6 hour outage for the upgrade.**
6. Identify a time window that works for the development team and AppSRE to upgrade the production database.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
   2. Upgrades should be started early in the morning. AppSRE will not approve upgrades that start after 10am ET.
7. Notify your customers of the planned outage by posting the necessary banners on `Pendo` and `Statuspage`.
8. Execute the upgrade in production.

### Note About Upgrading Read-Replicas

Upgrading RDS instances that have read-replicas is a bit more complicated for PostgreSQL. AWS recommends that you **delete and recreate read-replicas after the source instance has upgraded to a different major version.**

## app-interface changes for upgrading

This section provides the high-level steps required to perform the major version upgrade using app-interface. This section should be used to create the step-by-step instructions specific to the database that is being upgraded.

---

**Several of the steps below will require an AppSRE team member to complete them. This is not a self-service process. Do not attempt to perform these steps without having read the earlier sections and having scheduled time with AppSRE.**

---


### 1. Terminate Read Replicas

#### Remove Read Replica Dependency

1. Deploy configuration changes so that your application will stop using read replica instance.

#### Read Replicas Termination and Config Updates

1. Update your parameter group to remove any parameters related to replication.
2. Raise MR to app-interface to delete the read-replica instance. This step will have to executed by AppSRE team member. Remember to set `deletion_protection` to `false` for the read replica instance.
3. Drop the `Logical replication slots`. This step will have to executed by AppSRE team member. If the database is using logical replication slots, the major version upgrade fails and shows the message `PreUpgrade checks failed: The instance could not be upgraded because one or more databases have logical replication slots. Please drop all logical replication slots and try again`. To resolve the issue, stop any running DMS or logical replication jobs and drop any existing replication slots. See the following code:

```
   SELECT * FROM pg_replication_slots;
   SELECT pg_drop_replication_slot(slot_name);
```
In case the slot can not be dropped with the following error: `ERROR:  replication slot "slot_name" is active for PID XXXXX`:
```
   SELECT pg_cancel_backend(pid);
```

Example MR: [Terminate read-replica](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9692)

### 2. Create a New Parameter Group and Update Engine Version

Create a copy of your current parameter group and update at least following 2 things:

1. `family` : The family of the DB parameter group.
2. `name` : The name of the DB parameter group. Must be unique.

At this point the file exists but is not referenced by your RDS instance. This change can be combined with next step.

1. Update the `engine_version` for your RDS instance in either the defaults file or add it to overriding section.
   * **IMPORTANT:** if changing a defaults file, you will upgrade every database that uses that defaults file, so take care in changing this setting. You can grep for the defaults filename to see where it is used and confirm that only the expected databases will be changed in the MR dry-run build.
2. Add `allow_major_version_upgrade: true` to your RDS defaults file to allow upgrade. Terraform will fail if this flag is not set.
3. Update `parameter_group` reference to use the new parameter group file.
4. The MR will be reviewed by the AppSRE team. They will not merge the MR until the upgrade is ready to begin.

Example MRs: [Upgrade RDS Instance from PostgreSQL 10.x to 11.6 & Create PostgreSQL 11 parameter group](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9698/diffs)

### 3. Scale DOWN the application

Raise MR that sets the deployment's replica count to `0`.

Example MR: [Scale down service](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9695)

### 4. Start Database Upgrade

Start by merging the MR that was created to upgrade the database. When qontract-reconcile runs next, the upgrade should be scheduled for the next maintenance window.

**When you're ready to begin the upgrade**, run the command below so that the pending RDS modifications are applied immediately:

```
aws rds modify-db-instance --db-instance-identifier <DATABASE_NAME> --region <REGION> --apply-immediately
```

---

**Note:** If you don't run the command above, then the upgrade will not happen until the next maintenance window.

---

Monitor the upgrade in AWS console. AWS will run a pre-upgrade check and the upgrade may not proceed if pre-upgrade check fails. The AWS docs linked above have troubleshooting steps if you run into errors with pre-upgrade checks.

---

**If you see errors related to deleting parameter group errors, then see the next section. Otherwise, you can skip to the next step.**

---

#### Parameter group errors

qontract-reconcile may fail in applying the upgrade if the parameter group is only being used by a single database because the current parameter group can't be deleted until the upgrade is done. Expect an error similar to following:

```
[terraform-resources] error: b'\nError: Error deleting DB parameter group: InvalidDBParameterGroupState: One or more database instances are still members of this parameter group steahan-dev-params, so the group cannot be deleted\n\tstatus code: 400, request id: 417e8bab-3959-40e5-8a7b-39d18b984f8e\n\n\n'
[terraform-resources] [app-sre-stage - apply] Error: Error deleting DB parameter group: InvalidDBParameterGroupState: One or more database instances are still members of this parameter group steahan-dev-params, so the group cannot be deleted
[terraform-resources] [app-sre-stage - apply]     status code: 400, request id: 417e8bab-3959-40e5-8a7b-39d18b984f8e
```

**If you see the error above**, you have two options, either copy the existing custom parameter group, or use the default parameter group temporarily.

#### Option A: Copy custom parameter group

Copying the existing parameter group is technically the safest path unless the tenant team indicates that using the default parameter group for a short period of time is safe. The steps below will copy the existing parameter group and apply it to the RDS instance so that the old parameter group can be deleted.

```
# Create a '-copy' version of the parameter group
aws rds copy-db-parameter-group --source-db-parameter-group-identifier <EXISTING_PARAMETER_GROUP> --target-db-parameter-group-identifier <EXISTING_PARAMETER_GROUP>-copy --target-db-parameter-group-description "Copy of <EXISTING_PARAMETER_GROUP> to be used during major version upgrade"

# Switch to the '-copy' version of the parameter group so that the old parameter group can be deleted
aws rds modify-db-instance --db-instance-identifier <DATABASE_NAME> --region <REGION> --apply-immediately --db-parameter-group-name <EXISTING_PARAMETER_GROUP>-copy
```

#### Option B: Use default parameter group

```
aws rds modify-db-instance --db-instance-identifier <DATABASE_NAME> --region <REGION> --apply-immediately --db-parameter-group-name default.postgres<VERSION>

# Example
aws rds modify-db-instance --db-instance-identifier my-database --region us-east-1 --apply-immediately --db-parameter-group-name default.postgres10
```

### 5. Scale UP the application

When the RDS instance status changes to `Available`, scale the application back to usual capacity. At this point your application will still not use read-replica as none exist.

Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9716

### 6. Create read-replicas

Now re-create the read-replica instances by adding them back to app-interface.

### 7. Update Application Config Changes to use read replicas

Update your application configuration to use the read replicas.

### 8. Post-upgrade steps

1. If [parameter group errors](#parameter-group-errors) were detected and a `-copy` parameter group was created, then delete that parameter group.
