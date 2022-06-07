# Common Database Restore Activities

This document covers steps that are common across the different methods for restoring an RDS database.

## Before restoring a database

Before restoring a database from a backup:

1. **[Optional]** Decide whether it's best to leave the service running in a degraded state or scale the service down. There are trade-offs such as whether the service continues to make updates to the database that will be lost after the backup is restored, or whether this data will need to be merged later.

## After restoring a database

### Access Required

1. Access to merge MRs to app-interface
2. Access to take snapshots and/or stop RDS instances

Given the access required, an AppSRE engineer will be required to execute most of the steps below (service team can prepare MRs).

### Steps

After the service team is confident that the restored database is working as expected, see the follow-up tasks below:

1. **[Optional]** [Snapshot the original database](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateSnapshot.html) and stop the database unless the service team needs data from the two instances merged. Stopping the database ensures that it's impossible for anything to be connecting to the old database.
   * An RDS instance will start again after 7 days of being stopped. So, it's best to immediately move to the next step unless there is an exceptional reason for leaving it stopped.
    ```
   # To stop the database and take a snapshot at the same time
   aws rds stop-db-instance --db-instance-identifier <identifier> --db-snapshot-identifier <identifier>-restore-<date>
   
   # Take a snapshot only
   aws rds create-db-snapshot --db-instance-identifier <identifier> --db-snapshot-identifier <identifier>-restore-<date>
   ```   
2. Delete the original database
   * **Double-check that a manual snapshot of the database exists before deleting it!**
   * As with everything else, the database should be [deleted using app-interface](https://gitlab.cee.redhat.com/service/app-interface#enable-deletion-of-aws-resources-in-deletion-protected-accounts)
