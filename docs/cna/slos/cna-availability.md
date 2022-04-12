# CNA  - Availability SLO/SLI

## SLI description

We are measuring the percentage of requests that resulted in a successful
response from provided user api endpoints.


## SLI Rationale

CNA is expected to be available and provide successful responses
to teams in Red Hat managing services to maintain a good user experience.

## Implementation details

We count the number of API requests that do not have a 5xx status code and divide it by the
total of all the API requests made. It is measured at the router using the
`haproxy_backend_http_responses_total` metric.

## SLO Rationale

CNA is expected to be available 90% of the time. This can be increased once this availability
SLO has been observed with performance tests in production over a longer period of time.

## Alerts

The following are the multi-window, multi-burn-rate alerts that are associated with this SLO.

- ErrorBudgetBurn
