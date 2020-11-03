# Receptor-Controller SLOs

## SLO

Availability:
99% of websocket requests result in successful (non-5xx) response
99% of message submission / connection management requests result in successful (non-5xx) response
99% of responses are successfully delivered to kafka


## SLI

Availability:

WebSocket Errors (5xx) %:
`sum(increase(api_3scale_gateway_api_status{exported_service="receptor-controller", status="5xx"}[$__range])) / sum(increase(api_3scale_gateway_api_status{exported_service="receptor-controller"}[$__range]))`

API Errors (5xx) %:
sum(increase(receptor_controller_http_status_code_counter{status_code=~"5[0-9]{2}"})) / sum(increase(receptor_controller_http_status_code_counter))

Response Delivery Errors %:
`sum(increase(receptor_controller_kafka_response_writer_failure_count[$__range])) / sum(increase(receptor_controller_payload_message_sizes_count[$__range]))`

## Dashboards

https://grafana.app-sre.devshift.net/d/FRmd1NeWk1/receptor-controller?orgId=1
