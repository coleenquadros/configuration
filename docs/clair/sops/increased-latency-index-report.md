# Indexer increased latency for GETting reports

## Description:
Quay's UI will request a Vulnerability Report from a Clair matcher for every tag that appears in the tags view, to fulfil this request the matcher will ask an indexer for an index report. This is typically a low latency operation ranging from 0.05s to 0.1s and consistently high latency suggests a system problem.

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
- If the Indexer DB has high connections (> number of indexer pods * 20) it's possible there is a connection leak.
- If DB storage is full, then the application is unable to persist anything and look ups will probably slow down drastically as table locks are held for longer.
- If the DB resources are saturated then it's possible requests to the DB being completed slowly.
- If the logs don't seem to show any errors it is possible the indexer pods are running out of CPU and are being throttled, this can be determined through [these pod dashboards](pod_dashboards.md).
## Resolution steps:
- If it is found to be a networking issue then steps should be taken on the infrastructure side to rectify the problem.
- If it is found to be a problem with DB storage resources then increases should be made, adding storage can be done online and 500Gb should be added immediately.
- If it is found to be a problem with DB compute resources then it is likely a bigger RDS instance type will be needed, this should be escalated to Quay oncall as it will likely incur downtime.
- If the indexer pods are constantly hitting the defined CPU limit then the CPU limit should be increased by 500mCPU.
- If no resolution is found then scaling the indexer pods can also be done to spread the load. However, care should be taken to ensure the indexer DB is still operating in safe bounds (i.e. CPU is below 80% usage and Memory isn't becoming saturated).
- If no resolution is found, escalate Quay oncall.
