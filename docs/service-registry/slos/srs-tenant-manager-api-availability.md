# Service Registry Service - Tenant Manager API - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints external users can interact with.

## SLI Rationale
The Tenant Manager API is a critical component in the Managed Service Registry ecosystem, it is expected to be available and responding successfully to requests. Both SRS-fleet-manager and Service Registry depend on its API to function properly.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests made. 
This component is not accessed through an Openshift route, so it's measured using the metric `rest_requests_count_total` from the service.

## SLO Rationale
Tenant Manager is expected to be available 95 percent of the time. This can be increased to 99.9 once this availability SLO has been proven in production over a longer period of time.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `SRSTenantManagerAPI30mto6hErrorBudgetBurn`
- `SRSTenantManagerAPI2hto1dErrorBudgetBurn`
- `SRSTenantManagerAPI6hto3dErrorBudgetBurn`
  
