# Restore RDS database to a specific point in time

The RDS [point-in-time recovery](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html) feature allows users to create a new database from a backup at any point in the backup retention window up to the `LatestRestorableTime` of the RDS instance. The `LatestRestorableTime` is the last time that RDS shipped transaction logs to S3, which should be every 5 minutes.

## Access Required

This SOP requires the following access:

1. Access to merge MRs to app-interface
2. Read access for RDS resources, or access to AppSRE Prometheus instances
3. Access to take snapshots and/or stop RDS instances

Given the access required, an AppSRE engineer will be required to execute certain steps in this SOP, but many of the steps can be prepared by a service team with the read access noted above.

## Steps

The steps below can be followed to recover a database that needs to be restored from a backup to a specific point in time.

1. See [Before restoring a database](/docs/aws/sop/common-database-restore-activities.md#before-restoring-a-database)
2. Find the `LatestRestorableTime` using one of the methods below:
   * [AWS console](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html)
   * AWS CLI:
        ```
        aws rds describe-db-instances --db-instance-identifier <db_name> --query 'DBInstances[].LatestRestorableTime'
        ```
   * Check the `aws_resources_exporter_rds_latestrestorabletime` metric exposed by aws-resource-exporter - [prod accounts](https://prometheus.app-sre-prod-01.devshift.net/graph?g0.expr=aws_resources_exporter_rds_latestrestorabletime&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h) (app-sre, insights-prod, etc.) - [stage accounts](https://prometheus.app-sre-stage-01.devshift.net/graph?g0.expr=aws_resources_exporter_rds_latestrestorabletime&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h) (app-sre-stage, insights-stage)
3. Create a new database using the point in time recovery feature. See below for an example:
    ```diff
    terraformResources:
      - provider: rds
        account: <account-name>
        identifier: <identifier>
        defaults: <defaults-file>
        overrides:
    +     name: <database_name>  # Remove `name` from defaults file and explicitly set it only on the original database (read more below)
    +
    + - provider: rds
    +   account: <account-name>
    +   identifier: <identifier>-restore
    +   defaults: <defaults-file>
    +   overrides:
    +     timeouts:
    +       create: 2h
    +     restore_to_point_in_time:
    +       restore_time: '2022-06-01T20:43:00Z'  # Insert the actual restore_time, this is kept for an example of how to format it
    +       source_db_instance_identifier: <identifier>
    ```
   * `name` must be removed from the defaults file because a new database cannot be created using `restore_to_point_in_time` with `name` set. Alternatively, create a new defaults file by copying the existing one and removing `name`.
   * `identifier` can be any name, but this will be the permanent name of the database unless we need to restore again in the future
   * `restore_time` can be set to any time (down to the second) in the backup retention window (see `backup_retention_period`) before `LatestRestorableTime`
4. Merge the MR and wait for the new database to be created.
5. Once the new database is available, connect to it manually to ensure that the data is in the expected state.
   * **You will need to use the password from the Secret of the original database.** This will be fixed in the next steps.
6. By now the restored database data should be verified. The remaining step is to update the `Secret` to match the secret of the original database. This prevents the need for changing anything at the application level. An example can be seen below.
    ```diff
    terraformResources:
      - provider: rds
        account: <account-name>
        identifier: <identifier>
        defaults: <defaults-file>
    +   output_resource_name: <identifier>-rds-old
        overrides:
          name: <database_name>
    
      - provider: rds
        account: <account-name>
        identifier: <identifier>-restore
        defaults: /terraform/resources/app-sre-stage/staging/steahan-rds-defaults.yml
    +   output_resource_name: <identifier>-rds  # Alternatively, if `output_resource_name` was already set on the original database, use that value
    +   reset_password: restore-<identifier>
        overrides:
          timeouts:
            create: 2h
          restore_to_point_in_time:
            restore_time: '2022-06-01T20:43:00Z'
            source_db_instance_identifier: <identifier>
    ```
   * `reset_password` is set to force a reset of the database password. This is needed because the database will be created with the password from the original database (see: APPSRE-5729)
   * Swapping `output_resource_name` makes it so that the restored database now takes over the `Secret` name from the original database. This means that any `Secret` refs can remain unchanged. Note that if the original database had not set `output_resource_name`, then it will be `<identifier>-rds`.
7. Merge the MR to switch the `Secret`s. Once this is complete, `qontract.recycle` should result in the restart of any pods using this secret.
8. Ensure that the new database is showing the expected number of connections (see CloudWatch) and that the old database has 0 connections
9. See [After restoring a database](/docs/aws/sop/common-database-restore-activities.md#after-restoring-a-database)
