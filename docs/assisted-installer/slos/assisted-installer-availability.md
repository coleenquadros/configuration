# Assisted Installer - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints external users can interact with.

## SLI Rationale
The Assisted-Installer API is a component in the Openshift ecosystem, it is expected to be available and responding successfully to requests.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests.
It is measured at the router using the `haproxy_backend_http_responses_total` metric.

## SLO Rationale
Assisted-installer is expected to be available 85% of the time.
There is no one on-call on Saturdays, therefore, according to 6/7 days a week we get that SLO.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `ErrorBudgetBurn`
