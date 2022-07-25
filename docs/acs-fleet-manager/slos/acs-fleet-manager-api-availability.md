# ACS Fleet Manager API - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints external users can interact with.

## SLI Rationale
The ACS fleet manager API is a critical component, it is expected be available and responding successfully to requests.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests made. 
It is measured at the router using the `haproxy_backend_http_responses_total` metric.

## SLO Rationale
ACS fleet manager is expected to be available 99 percent of the time on production. This might be tuned in the future onc ethe service is running on production.

## Alerts

TODO
  
