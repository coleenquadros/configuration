# cloudigrade SLOs

## SLO

* Availability: HTTP requests respond with successful status (non-5xx) 95% of the time
* Latency: HTTP requests respond in <= 4000 ms 95% of the time

## SLI

* [Availability prometheus query using 1-week window](https://prometheus.crcp01ue1.devshift.net/graph?g0.expr=sum(rate(%0A%20%20api_3scale_gateway_api_status%7Benvironment%3D%22prod%22%2C%20exported_service%3D%22cloudigrade%22%2C%20status!%3D%225xx%22%7D%5B1d%5D%0A))%20%2F%20sum(rate(%0A%20%20api_3scale_gateway_api_status%7Benvironment%3D%22prod%22%2C%20exported_service%3D%22cloudigrade%22%7D%5B1d%5D%0A))&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h)
* [Latency prometheus query using 1-week window](https://prometheus.crcp01ue1.devshift.net/graph?g0.expr=sum(rate(%0A%20%20api_3scale_gateway_api_time_bucket%7Bexported_service%3D%22cloudigrade%22%2C%20le%3D%224000.0%22%7D%5B1d%5D%0A))%20%2F%20sum(rate(%0A%20%20api_3scale_gateway_api_time_bucket%7Bexported_service%3D%22cloudigrade%22%2C%20le%3D%22%2BInf%22%7D%5B1d%5D%0A))&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h)

## Dashboards

* [cloudigrade grafana dashboard](https://grafana.app-sre.devshift.net/d/O6v4rMpizda/cloudigrade?orgId=1&refresh=1m&var-datasource=crcp01ue1-prometheus&var-namespace=cloudigrade-prod&var-datasource_rds=app-sre-prod-01-prometheus)

## SOPs

* [cloudigrade alert response SOPs](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/console.redhat.com/app-sops/cloudigrade/)
