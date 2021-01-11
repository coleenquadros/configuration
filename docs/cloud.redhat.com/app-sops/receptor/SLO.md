# Receptor-Controller SLOs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. WebSocket Server
1. HTTP API Server
1. Kafka Producer

## SLIs
1. Percentage of successful (non-5xx) WebSocket requests made to the API in the past 24 hours
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
1. Percentage of correctly-formatted messages ingested from receptor nodes, which are successfully delivered to kafka in the past 24 hours.

## SLOs

1. `> 95%` of WebSocket requests are non-5xx
1. `> 95%` of message submission / connection manaagement API requests are non-5xx
1. `> 95%` of responses are successfully delivered to kafka

## Dashboards

https://grafana.app-sre.devshift.net/d/FRmd1NeWk1/receptor-controller?orgId=1
