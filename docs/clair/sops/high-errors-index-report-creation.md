# Indexer increase 500s for creating reports

## Description:
Quay's security worker will submit manifests to Clair to perform indexing (creating an inventory of the installed software in the container). When Clair experiences an unexpected error in the indexing process it will return a 500 status code.

## Observed:
- [Grafana dashboard](https://grafana.app-sre.devshift.net/d/I1JBFlRnz/clair-v4?orgId=1&var-rate=1m&var-dbquantile=0.95&var-apiquantile=0.20&var-datasource=clairp01ue1-prometheus&viewPanel=7)

## Debugging steps:
- Browse to the logs in [Cloudwatch](logs.md)
- Use the query:
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter level = "error"
| sort @timestamp desc
```
- If, from the logs, the issue seems database related or there are multiple context timeouts in the logs, go to the [Grafana RDS dashboard](db_dashboards.md) and check how things look.
- If the Indexer DB has no connections then probably there is a networking problem between Clair and RDS.
- If the logs mention failure to fetch layers, there is most likely a problem with Clair's access to Quay's storage, in production this is a signed S3/Cloudfront URL.
- If DB storage is full, then the application is unable to persist anything.
- If the DB resources are saturated then it's possible requests to the DB are timing out or failing completely.
- If the logs don't seem to show any errors it is possible the indexer pods are running out of resources and are being restarted, this can be determined through [these pod dashboards](pod_dashboards.md) and going through the debugging steps [here](pods-restarting.md).
## Resolution steps:
- If it is found to be a networking issue then steps should be taken on the infrastructure side to rectify the problem.
- If it is found to be a problem with DB storage resources then increases should be made, adding storage can be done online and 500Gb should be added immediately.
- If the problem is due to Clair not being able to access Quay's storage this should be escalated to Quay oncall.
- If it is found to be a problem with DB compute resources then it is likely a bigger RDS instance type will be needed, this should be escalated to Quay oncall as it will likely incur downtime.
- If the indexer pods are restarting because of exhausted memory resources then memory limits and requests should be evaluated and increased, adding 500Mb of memory to the requested amount and redeploying. (Note: Scaling the indexer pods can also be done to spread the load. However, because of their spikey CPU usage increasing the requested memory will probably be more effective).
- If no resolution is found, escalate Quay oncall.
