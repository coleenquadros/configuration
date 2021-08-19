# Assisted Installer - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The Assisted-Installer API is a component in the Openshift ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
We count the number of successful API requests that are sufficiently fast and divide it by the total of all the successful API requests.
It is measured at the router using the `http_request_duration_seconds` metric.

## SLO Rationale
Assisted-installer is expected to serve at lest 90% of the requests in less than 1[s].
More than 95% of the requests are actually served in less than 100[ms] but some APIs are more expensive like 'Get /clusters',
especially for admins which fetch all the clusters of all the users in the cloud, therefore, a security margin was taken.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `LatencyBudgetBurn`
