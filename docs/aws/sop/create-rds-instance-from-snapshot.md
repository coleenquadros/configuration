# Create RDS database from Snapshot

You may want to restore or create a database from a snapshot for several reasons including:

1. Recovering a database using an automated snapshot taken before a major/minor version upgrade
2. Recovering a database using a manual snapshot taken before some other impactful operation
3. Creating a database for testing purposes using an existing dataset

Note that by default RDS only takes **automated snapshots every 24 hours**, so if you wish to recover a database with minimal data loss, and don't have a manual snapshot or pre-upgrade automated snapshot, then you probably want to look at [Restore RDS database to a specific point in time](#restore-rds-database-to-a-specific-point-in-time).

It's also worth noting that a database cannot be restored from a snapshot in-place. Instead, a new RDS instance will have to be created. See below for the steps involved in creating a database from a snapshot.

## Access Required

This SOP requires the following access:

1. Access to merge MRs to app-interface
2. Read access for RDS resources
3. Access to take snapshots and/or stop RDS instances

Given the access required, an AppSRE engineer will be required to execute certain steps in this SOP, but many of the steps can be prepared by a service team with the read access noted above.

## Steps

----

**Note:** this is a reminder to consult service-specific disaster recovery procedures before beginning. This steps below assume that applications rely directly on a `Secret` name specified by `output_resource_name`. For use cases that include other mechanisms for determining which database to use, including by not limited to **Clowder**, additional steps may be necessary.

----

1. See [Before restoring a database](/docs/aws/sop/common-database-restore-activities.md#before-restoring-a-database)
2. Find the snapshot identifier for the snapshot that you'd like to create a new RDS instance for using one of the methods below:
   * [AWS Console](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html#USER_RestoreFromSnapshot.Restoring)
   * AWS CLI:
        ```
        aws rds describe-db-snapshots --db-instance-identifier <instance> --query 'DBSnapshots[].[DBSnapshotIdentifier,SnapshotCreateTime,SnapshotType]'
        ```
   * **Note:** snapshot identifiers will be prefixed with `rds` for automated snapshots, like `rds:<identifier>-2022-05-26-04-28`, whereas manual snapshots will not have this prefix
3. Create a new database using the `snapshot_identifier` feature as seen below:
    ```diff
    terraformResources:
      - provider: rds
        account: <account-name>
        identifier: <identifier>
        defaults: <defaults-file>
    +
    + - provider: rds
    +   account: <account-name>
    +   identifier: <identifier>-restore
    +   defaults: <defaults-file>
    +   overrides:
    +     snapshot_identifier: <snapshot_name>
    +     timeouts:
    +       create: 2h
    ```
4. Merge the MR and wait for the new database to be created.
5. Once the new database is available, connect to it manually to ensure that the data is in the expected state.
6. By now the restored database data should be verified. The remaining step is to update the `Secret` to match the secret of the original database. This prevents the need for changing anything at the application level. An example can be seen below.
    ```diff
    terraformResources:
      - provider: rds
        account: <account-name>
        identifier: <identifier>
        defaults: <defaults-file>
    +   output_resource_name: <identifier>-rds-old
    
      - provider: rds
        account: <account-name>
        identifier: <identifier>-restore
        defaults: /terraform/resources/app-sre-stage/staging/steahan-rds-defaults.yml
    +   output_resource_name: <identifier>-rds  # Alternatively, if `output_resource_name` was already set on the original database, use that value
        overrides:
          timeouts:
            create: 2h
          restore_to_point_in_time:
            restore_time: '2022-06-01T20:43:00Z'
            source_db_instance_identifier: <identifier>
    ```
   * Swapping `output_resource_name` makes it so that the restored database now takes over the `Secret` name from the original database. This means that any `Secret` refs can remain unchanged. Note that if the original database had not set `output_resource_name`, then it will be `<identifier>-rds`.
7. Merge the MR to switch the `Secret`s. Once this is complete, `qontract.recycle` should result in the restart of any pods using this secret.
8. Ensure that the new database is showing the expected number of connections (see CloudWatch) and that the old database has 0 connections
9. See [After restoring a database](/docs/aws/sop/common-database-restore-activities.md#after-restoring-a-database)
