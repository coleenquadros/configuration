# Remediations SLOs

## SLO

Fewer than 5% of requests result in 5xx response every 10 minutes

Fewer than 5% of requests are served within 2 seconds

Fewer than 5% of connector requests result in 5xx response every 10 minutes

At least one Kafka message processed every 5 minutes

## SLI

Availability: `sum(increase(remediations_http_request_duration_seconds_count{namespace=~"remediations-prod", status_code=~"5[0-9]{2}"}[10m])) / sum(increase(remediations_http_request_duration_seconds_count{namespace=~"remediations-prod"}[10m]))`

Latency: `sum(increase(remediations_http_request_duration_seconds_bucket{namespace="remediations-prod", le="2.1"}[6h] or up * 0) / sum(increase(remediations_http_request_duration_seconds_count{namespace=~"remediations-prod"}[6h]))`

Connector requests: `sum(increase(remediations_connector_error{kubernetes_namespace="remediations-prod"}[10m]) or up * 0) / sum(increase(remediations_connector_summary_count[10m]))`

Number of Kafka messages processed: `sum(increase(remediations_consumer_messages_total{namespace="remediations-prod"}[5m]))`

## Dashboards

https://grafana.app-sre.devshift.net/d/KDvc-DmWk/remediations?orgId=1
