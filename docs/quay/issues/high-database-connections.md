# High connection count on Quay database instance

If you're getting paged for this, chances are that the service is already down or degraded. Before fixing the issue we must capture diagnostic information:

- Check the connection count on the AWS console, monitoring tab: https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc;is-cluster=false;tab=monitoring. Take a screenshot of this graph.
- Get a diagnostic dump of the RDS instance using the SOP: [quay-db-diagnostics.md](/docs/quay/sop/quay-db-diagnostics.md)
- Scale the service to 0 replicas: `oc scale deployment/quay-app --replicas=0`
- Wait until connections are back to 0 in the RDS console: https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc;is-cluster=false;tab=monitoring
- Analyze the dump, if the number of transaction_locks is > 10, then the DB must be rebooted. Otherwise continue to the next step.
- Scale the service to 30 replicas: `oc scale deployment/quay-app --replicas=30`

Note: consider 30 to be a placeholder, the right amount of replicas may be different.
