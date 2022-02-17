# Clair v4 - RDS dashboards

## RDS Monitoring in Grafana
### Stage
 - [Indexer](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1&var-datasource=AWS%20quayio-stage&var-region=default&var-dbinstanceidentifier=clair-indexer-stage&from=now-1h&to=now)
 - [Matcher](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1&var-datasource=AWS%20quayio-stage&var-region=default&var-dbinstanceidentifier=clair-matcher-stage&from=now-1h&to=now)
 - [Notifier](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1&var-datasource=AWS%20quayio-stage&var-region=default&var-dbinstanceidentifier=clair-notifier-stage&from=now-1h&to=now)

### Production
 - [Indexer](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1&var-datasource=AWS%20quayio-prod&var-region=default&var-dbinstanceidentifier=clair-indexer&from=now-1h&to=now)
 - [Matcher](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1&var-datasource=AWS%20quayio-prod&var-region=default&var-dbinstanceidentifier=clair-matcher&from=now-1h&to=now)
 - [Notifier](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?orgId=1&var-datasource=AWS%20quayio-prod&var-region=default&var-dbinstanceidentifier=clair-notifier&from=now-1h&to=now)
