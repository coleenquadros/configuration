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

1. Upgrade will take `3-6` hours and will require someone from AppSRE team to be available.
2. Confirm the upgrade path. Upgrading a `10.x` to `12.x` may look something like `10.10 => 11.8 => 12.3`.
3. Identify time window that works for dev team and SRE to upgrade in staging environment.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
4. Write Step by step instructions from developers for stopping the service before upgrade and starting the service after upgrade. If we do not want to stop the service during the upgrade time, we will need dev teams to monitor the service during upgrade process and document the expected behavior.
5. Assuming upgrades goes fine in staging, reach out to stakeholders and get approval to upgrade in production.
   1. **RDS upgrade will result in downtime for your application. Plan for 6 hour outage for the upgrade.**
   2. Upgrades should be started early in the morning. AppSRE will not approve upgrades that start after 11am ET.
6. Identify date and time for production upgrade.
   1. Open a JIRA ticket in [AppSRE backlog](https://issues.redhat.com/browse/appsre) for AppSRE approval and resource allocation for the upgrade.
7. Post necessary banners on `Pendo` and `Statuspage`.
8. Execute the upgrade in production.

## Note About Upgrading Read-Replicas

Upgrading RDS instances that have read-replicas is bit more complicated for PostgreSQL. AWS recommends that you **delete and recreate read-replicas after the source instance has upgraded to a different major version.**

## app-interface changes for upgrading

Make changes in following order.

### Terminate Read Replicas

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

### Create a New Parameter Group and Update Engine Version

Create a copy of your current parameter group and update at least following 2 things:

1. `family` : The family of the DB parameter group.
2. `name` : The name of the DB parameter group. Must be unique.

At this point the file exists but is not referenced by your RDS instance. This change can be combined with next step.

1. Update the `engine` version for your RDS instance in either the defaults file or add it to overriding section.
1. Add `allow_major_version_upgrade: true` to your RDS defaults file to allow upgrade. Terraform will fail if this flag is not set.
1. Update parameter group reference to use the file.
1. The actual upgrade step will have to executed by AppSRE team member.

Example MRs: [Upgrade RDS Instance from PostgreSQL 10.x to 11.6 & Create PostgreSQL 11 parameter group](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9698/diffs)

### Scale DOWN the application

Raise MR that set's the deployment's replica count to `0`.

Example MR: [Scale down service](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9695)

### Start Database Upgrade

#### Disable Terraform Resources (tf-r) integration in Production using Unleash

Disable the following integrations in [Unleash](https://app-interface.unleash.devshift.net/#/features):
- terraform-resources
- gitlab-housekeeping (to avoid accidental automated merges)

Note: Notify AppSRE IC & team.

#### Run Terraform Resources (tf-r) integration

Pull the latest copy of qontract-reconcile repo from upstream.

Run the Terraform Resources (tf-r) integration with `--dry-run` flag.

Example:

```sh
qontract-reconcile --config config.prod.toml --log-level INFO --dry-run terraform-resources
```

Verify that the only changes are to the resources you are modifying.


Run the Terraform Resources (tf-r) integration with `--enable-deletion` flag.

Example:

```sh
qontract-reconcile --config config.prod.toml --log-level INFO terraform-resources --enable-deletion
```

Note: When you run `tf-r`, it will fail because it won't be able to delete the current parameter group until the upgrade is done. Expect error similar to following:

```
[2020-09-23 10:05:23] [INFO] [terraform_client.py:log_plan_diff:176] - ['update', 'insights-prod', 'aws_db_instance', 'advisor-prod']
[2020-09-23 10:05:23] [INFO] [terraform_client.py:log_plan_diff:159] - ['destroy', 'insights-prod', 'aws_db_parameter_group', 'advisor-prod-pg']
[2020-09-23 10:05:23] [INFO] [terraform_client.py:log_plan_diff:153] - ['create', 'insights-prod', 'aws_db_parameter_group', 'advisor-prod-pg11']
[2020-09-23 10:09:32] [WARNING] [__init__.py:cmd:306] - error: b'\nError: Error applying plan:\n\n1 error occurred:\n\t* aws_db_parameter_group.advisor-prod-pg (destroy): 1 error occurred:\n\t* aws_db_parameter_group.advisor-prod-pg: Error deleting DB parameter group: InvalidDBParameterGroupState: One or more database instances are still members of this parameter group advisor-prod-pg, so the group cannot be deleted\n\tstatus code: 400, request id: a4367d47-2398-4134-93f6-3d4f1dfb26c1\n\n\n\n\n\nTerraform does not automatically rollback in the face of errors.\nInstead, your Terraform state file has been partially updated with\nany resources that successfully completed. Please address the error\nabove and apply again to incrementally change your infrastructure.\n\n\n'
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod] Error: Error applying plan:
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod] 1 error occurred:
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod]  * aws_db_parameter_group.advisor-prod-pg (destroy): 1 error occurred:
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod]  * aws_db_parameter_group.advisor-prod-pg: Error deleting DB parameter group: InvalidDBParameterGroupState: One or more database instances are still members of this parameter group advisor-prod-pg, so the group cannot be deleted
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod]  status code: 400, request id: a4367d47-2398-4134-93f6-3d4f1dfb26c1
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod] Terraform does not automatically rollback in the face of errors.
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod] Instead, your Terraform state file has been partially updated with
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod] any resources that successfully completed. Please address the error
[2020-09-23 10:09:32] [ERROR] [terraform_client.py:check_output:346] - [insights-prod] above and apply again to incrementally change your infrastructure.
```

In case previous step can't modify instance you can temporary switch instance to use copied version of parameter group:

1. Copy current parameter group and append something to it's name, like '-copy'
1. Modify RDS instance to use new copied parameter grpup
1. Wait for 'pending-reboot' status for paremeter group in the configuration tab
1. Reboot the instance
1. Re-run terraform-resource integration, this time it should success
1. Don't forget to delete copied patameter group after execution of actual upgrade

#### Apply RDS Modifications

NOTE: Create access key in AWS console and configure your AWS CLI prior to running the following command.

```sh
aws rds modify-db-instance --db-instance-identifier="RDS_IDENTIFIER" --db-parameter-group-name="NEW_PARAMETER_GROUP_NAME" --apply-immediately
```

Example:

```sh
aws rds modify-db-instance --db-instance-identifier="advisor-prod" --db-parameter-group-name="advisor-prod-pg12" --apply-immediately
```

Monitor the upgrade in AWS console. AWS will run a pre upgrade check and upgrade may not proceed if pre upgrade check fails. The AWS docs linked above have troubleshooting steps if you run into errors with pre upgrade checks.

### Enable Terraform Resources (tf-r) integration in Production using Unleash

Enable tf-r in production using unleash once upgrade is complete.

### Scale UP the application

When the RDS instance status changes to `Available`, scale the application back to usual capacity. At this point your application will still not use read-replica as none exists.

Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/9716

### Create read-replicas

Now re-create the read-replica instances.

### Update Application Config Changes to use read replicas

Update your application configuration to use the read replicas.
