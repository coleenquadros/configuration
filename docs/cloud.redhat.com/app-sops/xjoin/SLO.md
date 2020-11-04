# xjoin SLOs

## SLO

* Availability:  99% of requests result in successful response
* Latency:  95% of requests take less than 1500 ms to complete
* Consistency: 95% of the time host data stored in xjoin is in sync with Inventory

## SLI

* Availability: [1 - (sum(increase(xjoin_search_http_request_duration_seconds_count{status_code=~"5.*"}[7d])) or 0 + sum(increase(xjoin_search_errors_total{type="system"}[7d]))) / sum(increase(xjoin_search_http_request_duration_seconds_count[7d]))](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=1%20-%20(sum(increase(xjoin_search_http_request_duration_seconds_count%7Bstatus_code%3D~%225.*%22%7D%5B7d%5D))%20or%200%20%2B%20sum(increase(xjoin_search_errors_total%7Btype%3D%22system%22%7D%5B7d%5D)))%20%2F%20sum(increase(xjoin_search_http_request_duration_seconds_count%5B7d%5D))&g0.tab=1)
* Latency: [sum(increase(xjoin_search_http_request_duration_seconds_bucket{le="1.5"}[7d])) / sum(increase(xjoin_search_http_request_duration_seconds_bucket{le="+Inf"}[7d]))](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=sum(increase(xjoin_search_http_request_duration_seconds_bucket%7Ble%3D%221.5%22%7D%5B7d%5D))%20%2F%20sum(increase(xjoin_search_http_request_duration_seconds_bucket%7Ble%3D%22%2BInf%22%7D%5B7d%5D))&g0.tab=1)
* Consistency: SLI not currently available in Prometheus.
  A [Jenkins job](https://xjoin-jenkins.apps.crcp01ue1.o9m8.p1.openshiftapps.com/job/xjoin/job/validation-scheduled-light-prodv4/) periodically validates the data and fails if data is out of sync

## Dashboards

* [xjoin-search Dashboard](https://grafana.app-sre.devshift.net/d/eqi9ATJWz/xjoin-search?orgId=1&var-datasource=crcp01ue1-prometheus&var-interval=5m)
