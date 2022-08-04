
# RHSM Availability SLO/SLI

## SLI Description
We are measuring the percentage of requests that result in a successfully HTTP
response from external endpoints.

## SLI Rationale
RHSM Subscription Watch is a critical component for customers to manage and
track their subscription usage.  It is expected be available and responding
successfully to requests.

## Implementation Details
We count the number of requests that have a 5xx status code and divide it by the
total of all the API requests made.  We then subtract this value from one to
determine the percentage of successful requests.  The PromQL expression used is
as follows:

## SLO Rationale
5xx responses are a high-quality proxy for overall application health.

## Alerting
Alerts associated with this SLO:

* Rhsm5xx

Alerts should be kept to a medium level until on-boarding is complete.  There
are numerous issues that could cause an alert for this SLO and while breaking
this SLO might indicate an outage, it is not necessarily the case.
