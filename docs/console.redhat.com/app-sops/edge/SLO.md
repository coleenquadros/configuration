# Fleet Management SLOs and SLIs

## Categories

The following categories will correspond to the SLIs and SLOs below.

- Availability
- Latency

## SLIs

Availability: 1-(sum(rate(api_3scale_gateway_api_status{exported_service="edge",status="5xx"}[6h]))/sum(rate(api_3scale_gateway_api_status{exported_service="edge"}[6h]))) < .90

Latency: sum(api_3scale_gateway_api_time_bucket{exported_service="edge",le="2000.0"})/sum(api_3scale_gateway_api_time_bucket{exported_service="edge",le="+Inf"}) < .90

## SLOs

1. `> 90%` of requests result in successful (non-5xx) response 
2: `> 90%` of requests services in <2000ms

## Rationale

The given SLIs were determined based on the necessary components of the Fleet Management API. The main function of the API is to serve HTTP requests. Each of these components are paramount to the operability of the service and the platform.

## Error Budget

Error budgets are determined based on the SOP for each objective.


## Dashboards

TODO
[Fleet Management Grafana Dashboard]()
