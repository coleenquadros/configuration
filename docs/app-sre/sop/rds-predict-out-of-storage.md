# RDS burst balance getting exhausted

## Severity: High

## Impact

Applications using this DB will soon be unavailable

## Summary

The db instance will soon be out of storage and will not be available.

## Access required

* app-interface
* Grafana

## Investigation

The most straight forward resolution implies increasing the size of the RDS volume. This is an online operation that has no downtime in RDS. The downside of increasing the size of the RDS volume is that it is not a reversible operation: volumes size can be increased but never decreased.

To investigate further how pressing the situation is we can use the general [RDS Grafana dashboard](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1). Select the appropriate datasource (`AWS <aws account name>`) and the database. There's a dedicated panel for free storage.

The main causes for the volume getting full are:

* Changes in the write patterns. A new version makes too many writes, too many requests, etc...
* Slow query logs filling the volume. The slow query logs share the same volume than the data and may be the root cause. You can take a look into the amount of storage your logs are consuming using the `aws_resources_exporter_rds_logsstorage_size_bytes` metric. You can investigate it in [Prometheus](https://prometheus.app-sre-prod-01.devshift.net/graph?g0.expr=aws_resources_exporter_rds_logsstorage_size_bytes%7Bdbinstance_identifier%3D%22your-db-identifier%22%7D&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d), just replace `your-db-identifier` with the appropriate value.
* Small volume. There's nothing out of the ordinary, just the volume getting filled by usage.

## Resolution

If you have done whatever needs to be done application wise to reduce the amount of writes, there are a few things that can be done at a database level:

* Increase size using the `allocated_storage` property in your database defaults file or via an override if the defaults file is shared with other instances and also make sure that `apply_immediately` is also set to true or your changes won't take effect until the next maintenance window.
* If your instance has storage autoscaling enabled (`max_allocated_storage` property), increase autoscaling size.
* If you have determined that logs are the cause of the storage increase, there are a few postgres parameters that you can use to remediate:
  * `log_min_duration_statement` controls the minimum time (in ms) from which the queries will be written in the logs. Increasing it will diminish the size of the logs.
  * `rds.log_retention_period` will set the time (in minutes) the logs are stored. The minimum value of this is 1440 (1 day)
  * Bear in mind that the instance will need to have a custom parameter group associated and will get restarted if you associate a new one.

## Further info

* https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIOPS.StorageTypes.html
* https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.Parameters.html

## Notes

This alert is being changed from a catch-all alert to a per-resource alert as part of https://issues.redhat.com/browse/APPSRE-6680.

The alert will cause a Jira ticket to be created on a tenant's board.
