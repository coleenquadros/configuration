# Indexer increased latency for creating reports

## Description:
Quay's security worker will submit manifests to Clair to perform indexing (creating an inventory of the installed software in the container). This is typically a latent operation ranging from 3-10 seconds for novel images, however consistently high latency suggests a system problem.

## Observed:
- [Grafana dashboard](https://grafana.app-sre.devshift.net/d/I1JBFlRnz/clair-v4?orgId=1&var-rate=1m&var-dbquantile=0.95&var-apiquantile=0.20&var-datasource=clairp01ue1-prometheus&viewPanel=7)

## Debugging steps:
- Look for clues in the logs in [Cloudwatch](logs.md)
- Use the query:
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| sort @timestamp desc
```
- If, from the logs, the issue seems database related or there are multiple context timeouts in the logs, go to the [Grafana RDS dashboard](db_dashboards.md) and check how things look.
- If the Indexer DB has no connections then probably there is a networking problem between Clair and RDS.
- If the logs mention failure to fetch layers, there is most likely a problem with Clair's access to Quay's storage, in production this is a signed S3/Cloudfront URL.
- If DB storage is full, then the application is unable to persist anything.
- If the DB resources are saturated then it's possible requests to the DB are timing out or failing completely.
- If the logs don't seem to show any errors it is possible the indexer pods are running out of CPU and are being throttled, this can be determined through [these pod dashboards](pod_dashboards.md).
## Resolution steps:
- If it is found to be a networking issue then steps should be taken on the infrastructure side to rectify the problem.
- If it is found to be a problem with DB storage resources then increases should be made, adding storage can be done online and 500Gb should be added immediately.
- If it is found to be a problem with DB compute resources then it is likely a bigger RDS instance type will be needed, this should be escalated to Quay oncall as it will likely incur downtime.
- If the indexer pods are constantly hitting the defined CPU limit then the CPU limit should be increased by 500mCPU.
- If no resolution is found, escalate Quay oncall.
