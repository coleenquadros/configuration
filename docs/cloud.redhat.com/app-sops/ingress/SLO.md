# Ingress SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Payload Processing
3. Pod Uptime

## SLIs

1. Response Codes: sum(increase(ingress_responses{code=~"2.*"}[24h])) / sum(increase(ingress_responses[24h])) < .95
2. Uptime: avg(avg_over_time(up{service="upload-service"}[24h])) > .98
3. Kafka Production: sum(increase(ingress_kafka_produce_failures[24h])) / sum(increase(ingress_kafka_produced[24h])) > .95

## SLOs

1. `> 95%` of HTTP requests are non-5xx
2. `> 98%` uptime
3. `> 95%` of messages are placed onto kafka successfully

## Rationale
The given SLIs were determined based on the necessary components of the Ingress API. The main function of the API is to serve HTTP requests. Connectivity to Kafka is critical for the app to work with other applications on the platform. Each of these components are paramount to the operability of the service and the platform.

## Error Budget
Error budgets are determined based on the SOP for each objective.
