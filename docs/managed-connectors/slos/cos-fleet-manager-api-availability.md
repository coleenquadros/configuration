# Kafka Service Fleet Manager API - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints external users can interact with.

## SLI Rationale
The cos-fleet-manager API is a critical component in the RHOC ecosystem, it is expected be available and responding successfully to requests.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests made.
It is measured at the router using the `api_inbound_request_count` metric.

## SLO Rationale
cos-fleet-manager is expected to be available 95 percent of the time. This can be increased to 99.9 once this availability SLO has been proven in production over a longer period of time.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `CosFleetManagerAPI30mto6hErrorBudgetBurn`
- `CosFleetManagerAPI2hto1dErrorBudgetBurn`
- `CosFleetManagerAPI6hto3dErrorBudgetBurn`
  
