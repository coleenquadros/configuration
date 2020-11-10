# Host-Based Inventory SLOs

## SLO

Availability: Fewer than 5% HTTP 5xx responses over a 10 minute window

Latency: At least 95% of requests are served within 2 seconds

No Ingress host-processing errors

At least one Kafka message processed every 5 minutes

## SLI

Availability:  `sum(rate(inventory_http_request_total{namespace="host-inventory-prod", service="insights-inventory", status=~"5[0-9]{2}"}[10m])) by (namespace) / sum(rate(inventory_http_request_total{namespace="host-inventory-prod", service="insights-inventory"}[10m])) by (namespace)`

Latency:  `sum(rate(inventory_http_request_duration_seconds_bucket{namespace="host-inventory-prod", le="2.5"} [10m])) / sum(rate(inventory_http_request_duration_seconds_count{namespace="host-inventory-prod"} [10m]))`

Number of ingress processing errors: `sum(rate(inventory_ingress_add_host_failures_total{cause="Exception", namespace=~"host-inventory-.*"}[5m])) by (namespace)`

Number of Kafka messages processed: `sum(increase(inventory_ingress_add_host_successes_total{namespace="host-inventory-prod"}[5m])) by (namespace)`

## Dashboards

https://grafana.app-sre.devshift.net/d/EiIhtC0Wa/inventory?orgId=1
