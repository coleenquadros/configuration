# ROS SLOs

## SLO
Availability:  90% of requests result in successful (non-5xx) response 
Latency:  90% of requests services in <2000ms 

## SLI
Availability:  1.00 - (sum(rate(api_3scale_gateway_api_status{exported_service="ros", status="5xx"}[{{window}}])) / sum(rate(api_3scale_gateway_api_status{exported_service="ros"}[{{window}}])))
Latency:  avg_over_time(service:sli:latency_gt_2000:pctl10rate5m{exported_service="ros"}[{{window}}])

## Dashboards
https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&var-datasource=crcp01ue1-prometheus&var-label=ros

