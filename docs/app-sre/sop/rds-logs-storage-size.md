# RDS Logs storage size

## Severity: Medium

## Impact

Instances might end up being not accessible if they run out of storage. If instance reach a StorageFull state, the only way to solve the
problem is inreasing the storage size, which is not easy reversible and it increases the RDS instance cost.

## Summary

Database log files such as `error.log` or `slow.log` count as database storage size. If, for any reason, database logs get huge, the instance could end
up out of storage due to log files size. A real example of this is a query that gets logged repetedly into `slow.log` because it takes longer than the
configured threshold to be logged.

## Solutions

Check the current logs to find the cause why they are getting bigger. If it turned out that it is a query being logged to the `slow.log`
contact the tenant to get a diagnose. Additionally, consider increase the `log_min_duration_statement` parameter value to prevent the query
log.

### Delete Logs

#### PostgreSQL

The only way to delete logs is by reducing the retention period with the `log_retention_period` parameter in the parameter group.
Once the retention period is reduced, logs older than the retention period value will be deleted **at the next file rotation.**
File rotations are configured either with `log_rotation_age` and/or `log_rotation_size` parameters.

This can only be achieved if the instance has available storage. If the instance is already in a `Storage-full`
state, it's not possible to change parameters and the storage needs to be increased first.

## Access required

AWS account associated to the instance

## Further info

[RDS PostresSQL Logging](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.PostgreSQL.html)
