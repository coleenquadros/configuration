# Automation Hub SLIs and SLOs 

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Response (Availability)
2. Latency

## SLI Description
1. Percentage of successful (non-5xx) HTTP requests made to the API.
2. Percentage of successful HTTP requests completed under 2000ms.

## SLO Description

1. `>95%` of HTTP requests are successful over 28 days.
2. `>90%` of requests complete within 2000ms over 28 days. 

## Dashboards
App metrics: https://grafana.app-sre.devshift.net/d/0RsHCnNGz/automation-hub?orgId=1&from=now-24h&to=now&refresh=30s&var-Datasource=crcp01ue1-prometheus&var-namespace=automation-hub-prod

Database metrics: https://grafana.app-sre.devshift.net/d/spcmbCTGk/automation-hub-rds?orgId=1&from=now-24h&to=now&refresh=30s

SLO: https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&var-datasource=crcp01ue1-prometheus&var-label=automation-hub&refresh=1m
