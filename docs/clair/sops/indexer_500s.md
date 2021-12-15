# Indexer increase 500s for creating reports

## Description:
Quay's security worker will submit manifests to Clair to perform indexing (creating an inventory of the installed software in the container). When Clair experiences an unexpeced error in the indexing process it return a 500 status code.

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
- If it's database related, go to the [Cloudwatch DB](db_logs.md) and check how things look.
- If the Indexer DB has no connections then probably there is a networking problem between Clair and RDS.
- If the logs mention failure to fetch layers, there is most likely a problem with Clair's access to Quay's storage, in production this is a signed S3/Cloudfront URL.
- TODO: more scenarions

## Resolution steps:
- If it is found to be a networking issue then steps should be taken on the infrastucture side to rectify the problem.
- If it is found to be a problem with DB resources then increases should be made in consultation with both the AppSRE and Quay/Clair teams.
- If no resolution is found, call Quay oncall (TODO: link)