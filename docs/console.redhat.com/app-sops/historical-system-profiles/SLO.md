# Historical System Profiles SLOs

## SLO
Availability:  90% of requests result in successful (non-5xx) response 
Latency:  90% of requests services in <2000ms 

## SLI
Availability:  1.00 - (sum(rate(api_3scale_gateway_api_status{exported_service="historical-system-profiles", status="5xx"}[5m])) / sum(rate(api_3scale_gateway_api_status{exported_service="historical-system-profiles"}[5m])))
Latency:  avg_over_time(service:sli:latency_gt_2000:pctl10rate5m{exported_service="historical-system-profiles"}[30d]) > 0

## Dashboards
https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&var-datasource=crcp01ue1-prometheus&var-label=historical-system-profiles
