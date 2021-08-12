# 3scale SLOs

## SLO

Availability:  99% of requests result in successful (non-5xx) response 
Latency:  99% of requests services in <2000ms 

## SLI

Availability: avg_over_time(service:sli:status_5xx:pctl5rate5m{environment="prod",exported_service="api-cast-test"}[7d]) 
Latency:  avg_over_time(service:sli:latency_gt_2000:pctl10rate5m{environment="prod",exported_service="api-cast-test"}[7d])

## Dashboards

https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&from=now-7d&to=now&var-label=apicast-tests&var-datasource=crcp01ue1-prometheus
