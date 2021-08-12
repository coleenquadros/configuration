# Kafka Service Fleet Manager API - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints external users can interact with.

## SLI Rationale
The Kas-fleet-manager API is a critical component in the Managed Kafka ecosystem, it is expected be available and responding successfully to requests.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests made. 
It is measured at the router using the `haproxy_backend_http_responses_total` metric.

## SLO Rationale
Kas-fleet-manager is expected to be available 95 percent of the time. This can be increased to 99.9 once this availability SLO has been proven in production over a longer period of time.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `KasFleetManagerAPI30mto6hErrorBudgetBurn`
- `KasFleetManagerAPI2hto1dErrorBudgetBurn`
- `KasFleetManagerAPI6hto3dErrorBudgetBurn`
  
