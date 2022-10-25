# Subscription Watch SLOs

## SLO
API
 * Availability:  90% of requests result in successful (non-5xx) response 
 * Latency:  90% of requests services in <2000ms 


## SLI
API Availability: `1.00 - (sum(rate(api_3scale_gateway_api_status{exported_service="rhsm-subscriptions", status="5xx"}[5m])) / sum(rate(api_3scale_gateway_api_status{exported_service="rhsm-subscriptions"}[5m])))`

API Latency:  `sum(rate(api_3scale_gateway_api_time_bucket{le="2000.0", exported_service="rhsm-subscriptions"}[{{window}}])) / sum(rate(api_3scale_gateway_api_time_count{exported_service="rhsm-subscriptions"}[{{window}}]))`

## Dashboards

https://grafana.app-sre.devshift.net/d/lkPhH-1Zk/subscription-watch?orgId=1
