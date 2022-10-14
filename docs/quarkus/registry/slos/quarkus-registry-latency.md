# Quarkus Registry - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The Quarkus Extension Registry API is a component in the Openshift ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
We count the number of successful API requests that are sufficiently fast and divide it by the total of all the successful API requests.
It is measured at the router using the `http_request_duration_seconds` metric.

## SLO Rationale
The Quarkus Extension Registry is expected to serve at lest 90% of the requests in less than 1[s].
More than 95% of the requests are actually served in less than 100[ms] but some APIs are more expensive like POSTs to the admin endpoint, performed when a new Quarkus platform version or Quarkiverse extension is released.

## Alerts
All alerts are multi window, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `LatencyBudgetBurn`
