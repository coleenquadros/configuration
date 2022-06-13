# Upgrade Minor Version for PostgreSQL RDS Instance

**Before proceeding** ensure that you've read the [RDS minor version upgrades](/README.md#rds-minor-version-upgrades) documentation.

This document covers minor version upgrades to PostgreSQL RDS instances. These upgrades are intended to be backwards-compatible, but **you should always review the release notes**. Some things to know about minor versions upgrades in RDS:

1. **There isn't a direct rollback procedure for minor version upgrades.** RDS will take a snapshot before the upgrade begins. To revert to the old version, a new RDS instance can be created from this snapshot ([docs](/README.md#restoring-rds-databases-from-backups)).
2. **RDS downtime is not minimized during minor version upgrades with Multi-AZ**. This is because RDS stops Postgres on both the primary and standby during minor version upgrades. This may result in more downtime than what is expected from other similar operations like OS or instance upgrades that upgrade the standby first and then fail over to the primary.
3. RDS requires that read replicas be upgraded before the primary database (otherwise known as the `replica_source` in app-interface). This is covered in the sections below, but it is good to be aware of this limitation.

## Minor version upgrade process

This is the process for tenants to follow in order to upgrade the minor version of a PostgreSQL database. Please read this entire section carefully before proceeding with an upgrade.

---

**This process will result in at least 5 minutes of downtime, even if the instance is running in a Multi-AZ configuration.** Read the sections above for the explanation of why Multi-AZ doesn't save downtime for engine minor version upgrades.

---

1. Start by checking if there are any read replicas for the database (look for any `replica_source` settings with the database you're upgrading). If there aren't any replicas, proceed to step 2. If there are replica(s), the MR mentioned below can be created with the changes for both the replica and primary. You cannot apply the change to only the primary due to the previously mentioned limitations.
2. Find the RDS instances (primary and any replicas) in the app-interface `namespace-1.yml` file. Change the `engine_version` to the new minor version by setting it under `overrides`, or changing the default `engine_version` in the `defaults` file.
   * **IMPORTANT:** if changing a defaults file, you will upgrade every database that uses that defaults file, so take care in changing this setting. You can grep for the defaults filename to see where it is used and confirm that only the expected databases will be changed in the MR dry-run build.
3. This step will determine when the change will happen, whether it should be applied immediately, or during the next maintenance window.
   * **Production databases:** database upgrades typically need to occur during specific maintenance windows for production databases. RDS has a feature that will start database maintenance activities during [specific maintenance windows](/README.md#maintenance-windows-for-rds-instances). It is strongly suggested that tenants leverage this mechanism by omitting the `apply_immediately` option. 
     * AppSRE can not respond to high volumes of urgent MRs. The MR review and reconciliation SLOs are documented [here](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md#appsre-service-level-objectives). This is why we suggest strongly that teams avoid setting `apply_immediately: true` when RDS instances need to be upgraded during a certain maintenance window.
   * **Stage databases:** if the change can be applied at any time, and you'd prefer that it is applied as soon as AppSRE approves the MR, then set `apply_immediately: true` in the `overrides` section of the RDS resource. If `apply_immediately` is not set, your RDS instance will be upgraded during the next scheduled maintenance window.
4. Create an app-interface MR. Check the dry-run build results to ensure that only the expected databases are changed. Ask a team member to include their approval on the MR. AppSRE will review the MR as is done with all other changes.
5. The MR will be merged once AppSRE adds the **lgtm** label.
6. Wait for the change to be reconciled, you can monitor progress in [#sd-app-sre-reconcile](https://coreos.slack.com/archives/CS0E65QCV).
---

**Note:**
* You may see `DBUpgradeDependencyFailure` errors from the Terraform integration if upgrading the primary and replicas at the same time. This is expected because Terraform [doesn't gracefully handle RDS replica upgrades at this time](https://github.com/hashicorp/terraform-provider-aws/issues/22107). The errors should clear as soon as the replicas are upgraded. 
* You may also see `InvalidParameterValue` with a message indicating that a change is already in progress. This should only happen if `apply_immediately` is `false`. This should clear once the upgrade is complete.

---
6. If you did NOT set `apply_immediately: true`, then the database will be upgraded during the next scheduled maintenance window. If `apply_immediately` was set, then the database upgrade will have already started when the change was reconciled in step 5.
7. The RDS instance is shutdown to complete the upgrade. As noted above, this will **result in at least 5 minutes of downtime**. When complete, the database will have a status of `available` and will report the expected database engine version.
