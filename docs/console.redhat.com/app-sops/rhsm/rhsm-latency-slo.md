# RHSM Latency SLO/SLI

## SLI Description
We are measuring the latency of the RHSM app by tracking the number of requests
that require more than 2 seconds to service.

## SLI Rationale
RHSM Subscription Watch is a critical component for customers to manage and
track their subscription usage.  It is expected be responsive to requests.

## Implementation Details
We calculate the percentage of requests that take more than two seconds over a 15 minute window.
The PromQL expression used is as follows:

## SLO Rationale
A two second response time is more than enough for requests to the RHSM app.

## Alerting
Alerts associated with this SLO:

* RhsmLatency

Alerts should be kept to a medium level until on-boarding is complete.  There
are numerous issues that could cause an alert for this SLO and while breaking
this SLO might indicate an outage, it is not necessarily the case.
