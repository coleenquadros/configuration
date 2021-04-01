# Playbook Dispatcher SLOs

## SLO

1. More than 95% of HTTP requests are successful (i.e. the response code is other than 5xx)
1. More than 95% of HTTP requests is served within 2 seconds.
1. There is less than 10000 messages waiting to be processed 95% of the time. The sum of pending validator and response-consumer messages is considered.

## SLI

1. [HTTP success rate](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=1%20-%20(sum(increase(echo_http_requests_total%7Bstatus%3D%225xx%22%2C%20service%3D%22playbook-dispatcher-api%22%7D%5B1w%5D))%20%2F%20sum(increase(echo_http_requests_total%7Bservice%3D%22playbook-dispatcher-api%22%7D%5B1w%5D)))&g0.tab=1)
1. [HTTP latency](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=sum(increase(echo_http_request_duration_seconds_bucket%7Ble%3D%222%22%2C%20service%3D%22playbook-dispatcher-api%22%7D%5B1w%5D))%20%2F%20sum(increase(echo_http_request_duration_seconds_bucket%7Ble%3D%22%2BInf%22%2C%20service%3D%22playbook-dispatcher-api%22%7D%5B1w%5D))&g0.tab=1)
1. [Sum of pending messages](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=quantile_over_time(0.95%2C%20playbook_dispatcher%3Aconsumer_group_lag%3Asum%5B1w%5D)&g0.tab=1)

## Dashboards

* [Playbook Dispatcher dashboard](https://grafana.app-sre.devshift.net/d/js1xeMwMz/playbook-dispatcher?orgId=1&var-datasource=crcp01ue1-prometheus)
