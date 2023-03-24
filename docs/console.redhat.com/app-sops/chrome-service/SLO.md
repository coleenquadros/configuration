# Chrome Service SLOs and SLIs

## Categories

The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Response latency

## SLIs
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Percentage of API HTTP requests serviced in less than 2000ms in the past 24 hours

## SLOs
1. 90% of requests to service are successful (not-5xx)
2. 90% of requests to service return in less than 2000ms

## Rationale

The given SLIs were determined based on the necessary components of the chrome-service API. The main function of the API is to serve HTTP requests. Successful API responses and low latency are critical for achieving a good user experience for getting and setting favorite pages. It is an important component of the HAC app suite as well as dev-sandbox.

## Error Budget

Error budgets are determined based on the SLO for each objective.
