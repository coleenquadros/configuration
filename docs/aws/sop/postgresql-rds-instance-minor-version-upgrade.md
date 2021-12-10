# Upgrade Minor Version for PostgreSQL RDS Instance

This document covers minor version upgrades to PostgreSQL RDS instances. These upgrades are intended to be backwards compatible, but it is always good to review the release notes. Some things to know about minor versions upgrades in RDS:

1. **RDS downtime is not minimized during minor version upgrades with Multi-AZ**. This is because RDS stops Postgres on both the primary and standby during minor version upgrades. This may result in more downtime than what is expected from other similiar operations like OS or instance upgrades that upgrade the standby first and then fail over to the primary.
2. RDS requires that read replicas be upgraded before the primary database (otherwise known as the `replica_source` in app-interface). This is covered in the sections below, but it is good to be aware of this limitation.

## Manual Process

This is the manual process for upgrading the minor version of a PostgreSQL database. This is self-serviceable by tenants if they choose to use the `apply_immediately` option in app-interface, or if they only wish to schedule the upgrade for the next maintenance window. Tenants cannot queue an engine upgrade and then apply it manually using `aws rds modify-db-instance` because they generally don't have the required AWS access.

---

**This process will result in at least 3-5 minutes of downtime, even if the instance is running in a Multi-AZ configuration.** Read the sections above for the explanation of why Multi-AZ doesn't save downtime for engine minor version upgrades.

---

1. Start by checking if there are any read replicas for the database (look for any `replica_source` settings with the database you're upgrading). If there aren't any replicas, proceed to step 2. If there are replica(s), the MR mentioned below can be created with the changes for both the replica and primary. You cannot apply the change to only the primary due to the previously mentioned limitations.
2. Find the RDS instances (primary and any replicas) in the app-interface `namespace-1.yml` file. Change the `engine_version` by setting it under `overrides`, or changing the default `engine_version` in the `defaults` file. **Note:** if changing a defaults file, you will upgrade every database that uses that defaults file, so take care in changing this setting. You can grep for the defaults filename to see where it is used and confirm that only the expected databases will be changed in the MR dry-run build.
3. If you wish to apply the change as soon as app-interface reconciles the change, set `apply_immediately: true` in the `overrides` section of the RDS resource. Otherwise, your change will be queued for the next maintenance window. **You would typically want to avoid applying immediately if you have a large number of RDS instances to upgrade.** With a large number of instances, Terraform integration run times could be longer and you will have less control over exactly when the upgupgraderade occurs.
4. Create an app-interface MR. Check the dry-run build results to ensure that only the expected databases are changed. Get an approval from a team member and then have the change merged.
5. Wait for the change to be reconciled, you can monitor progress in [#sd-app-sre-reconcile](https://coreos.slack.com/archives/CS0E65QCV).
---

**Note:**
* You may see `DBUpgradeDependencyFailure` errors from the Terraform integration if upgrading the primary and replicas at the same time. This is expected because Terraform [doesn't gracefully handle RDS replica upgrades at this time](https://github.com/hashicorp/terraform-provider-aws/issues/22107). The errors should clear as soon as the replicas are upgraded. 
* You may also see `InvalidParameterValue` with a message indicating that a change is already in progress. This should only happen if `apply_immediately` is `false`. This should clear once the upgrade is complete.

---
6. If you did NOT set `apply_immediately: true`, then run the command below to apply the minor version upgrade when you are ready to do so. If you don't run this command, the database will be upgraded during the next maintenance window.
   ```
   aws --profile <AWS_PROFILE_NAME> rds modify-db-instance --db-instance-identifier <RDS_INSTANCE_NAME> --apply-immediately
   ```
7. The RDS instance is shutdown to complete the upgrade. As noted above, this will result in at least 3-5 minutes of downtime. When complete, the database will have a status of `available` and will report the expected database engine version:
   ```
   aws --profile <AWS_PROFILE_NAME> rds describe-db-instances --db-instance-identifier <RDS_INSTANCE_NAME> --query '[DBInstances[*].DBInstanceStatus,DBInstances[*].EngineVersion]' --output text
   ```
