# Compliance SLOs

## SLO
Availability:  90% of requests result in successful (non-5xx) response 
Latency:  90% of requests services in <2000ms 

## SLI
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/compliance-prod/compliance-prometheusrules.yaml

## Dashboards
https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&from=now-7d&to=now&var-datasource=crcp01ue1-prometheus&var-label=compliance
