# Receptor-Controller SLOs

## SLIs
1. Percentage of successful (non-5xx) WebSocket requests made to the API in the past 24 hours
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Percentage of correctly-formatted messages ingested from receptor nodes, which are successfully delivered to kafka in the past 24 hours.
3. Percentage of time that the pods remain in the UP state during the past 24h

## SLOs

1. `> 95%` of WebSocket requests are non-5xx
2. `> 95%` of message submission / connection manaagement API requests are non-5xx
3. `> 95%` of responses are successfully delivered to kafka
4. `> 98%` uptime

## Dashboards

https://grafana.app-sre.devshift.net/d/FRmd1NeWk1/receptor-controller?orgId=1
