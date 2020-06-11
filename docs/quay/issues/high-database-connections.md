# High connection count on Quay database instance

If you're getting paged for this, chances are that the service is already down or degraded. Keep calm and follow the exact steps listed here:

- Check the connection count on the AWS console, monitoring tab: https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc;is-cluster=false;tab=monitoring
- Get a diagnostic dump of the RDS instance using the SOP: link (docs/quay/sop/quay-db-diagnostics.md)
- Once you have captured the diagnostic information, follow the database restart SOP : link(docs/quay/sop/database-reboot.md)
