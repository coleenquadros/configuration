# Indexer rate limiting when creating reports

## Description:
Quay's security worker will submit manifests to Clair to perform indexing (creating an inventory of the installed software in the container). When the indexer receives more than `index_report_request_concurrency` requests concurrently it will return a 429 status code to avoid running out of resources and being killed. Config can be found [here](../../../resources/clair/production/clair-config-secret.yaml).

## Observed:
- [Grafana dashboard](https://grafana.app-sre.devshift.net/d/I1JBFlRnz/clair-v4?orgId=1&var-rate=1m&var-dbquantile=0.95&var-apiquantile=0.20&var-datasource=clairp01ue1-prometheus&viewPanel=7)

## Debugging steps:
- To double check the rate limiting you can browse to the logs in [Cloudwatch](logs.md)
- Use the query:
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter @message like "429"
| filter level = "error"
| sort @timestamp desc
```
- If indexing requests are being rate limited the production cluster isn't enough to deal with the indexing load.
## Resolution steps:
- Clair indexer pods should be scaled by 5 pods if cluster resources allow, the indexer [Grafana DB dashboard](db_dashboards.md) should be monitored when scaling up indexer pods to ensure resource utilization stays with acceptable bounds (i.e. CPU is below 80% usage and Memory isn't becoming saturated).
- If scaling indexer pods does not affect the number of requests being ratelimited, escalate Quay oncall.
