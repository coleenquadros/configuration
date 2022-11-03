# Cost Management SLOs

## SLO
API
 * Availability:  90% of requests result in successful (non-5xx) response 
 * Latency:  90% of requests services in <2000ms 


## SLI
API Availability: `1.00 - (sum(rate(api_3scale_gateway_api_status{exported_service="cost-management", status="5xx"}[{{window}}])) / sum(rate(api_3scale_gateway_api_status{exported_service="cost-management"}[{{window}}])))`

API Latency:  `sum(rate(api_3scale_gateway_api_time_bucket{le="2000.0", exported_service="cost-management"}[{{window}}])) / sum(rate(api_3scale_gateway_api_time_count{exported_service="cost-management"}[{{window}}]))`

## Dashboards

- https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?var-datasource=crcp01ue1-prometheus&var-label=cost-management
- https://grafana.app-sre.devshift.net/d/R0HueuFGk/cost-management?orgId=1&var-Datasource=crcp01ue1-prometheus&var-namespace=hccm-prod&var-db_instance=cost-management-prod&var-rds_datasource=app-sre-prod-01-prometheus
