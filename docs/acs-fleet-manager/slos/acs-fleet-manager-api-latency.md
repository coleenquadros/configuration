# ACS Fleet Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The ACS fleet manager API is a critical component, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
The SLO measures a server-side response time. 
It uses the `api_inbound_request_duration_bucket` histogram metric as the base of this SLO. 
The implementation is also only including successful responses, so the code label is added `,code!~"5.."`.

The p99 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 1000ms divided by the count of all of API HTTP requests.

The p90 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 100ms divided by the count of all of API HTTP requests.

## SLO Rationale
The p90 of 100ms and p99 of 1000ms were chosen based on approximate performance on production.

## Alerts

TODO
  
