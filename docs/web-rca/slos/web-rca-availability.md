# Web RCA  - Availability SLO/SLI

## SLI description

We are measuring the percentage of requests that resulted in a successful
response from provided user api endpoints.


## SLI Rationale

Web RCA, a tool that integrates with Status Board and other external systems like
JIRA and Bugzilla, is expected to be available and provide successful responses
to teams in Red Hat managing services to maintain a good user experience. 

## Implementation details

We count the number of API requests that do not have a 5xx status code and divide it by the
total of all the API requests made. It is measured at the router using the
`haproxy_backend_http_responses_total` metric.

## SLO Rationale

Web RCA is expected to be available 70% of the time. There is no one on-call on weekends, therefore, 
according to 5/7 days a week we get that SLO.

## Alerts

The following are the multi-window, multi-burn-rate alerts that are associated with this SLO.

- ErrorBudgetBurn
