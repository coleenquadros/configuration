# OSD Fleet Manager API - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints users can interact with. This is the <b>API availability</b>.
There are 2 sub-measures of the above measure:
1. The proportion of successful cluster's creation. This is the <b>cluster creation success rate</b>.
2. The proportion of successful cluster's deletiion. This is the <b>cluster deletion success rate</b>.

## SLI Rationale
The OSD Fleet Manager API is a critical component in any service ecosystem, it is expected to be available and responding successfully to requests.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests made. 
It is measured at the router using the `haproxy_backend_http_responses_total` metric.
Same applies for API sub-measures but only on `POST` and `DELETE` endpoints.

## SLO Rationale
A OSD Fleet Manager should be available 99 percent of the time.
An OSD Fleet Manager should have a success rate of 99 percent when responding the a cluster's creation or deletion request.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. 

The following are the list of alerts that are associated with the <b>API availability</b> SLO:
- `FleetManagerAPI30mto6hErrorBudgetBurn`
- `FleetManagerAPI2hto1dErrorBudgetBurn`
- `FleetManagerAPI6hto3dErrorBudgetBurn`

The following are the list of alerts that are associated with the <b>cluster creation success rate</b> SLO:
- `FleetManagerAPIClusterCreation30mto6hErrorBudgetBurn`
- `FleetManagerAPIClusterCreation2hto1dErrorBudgetBurn`
- `FleetManagerAPIClusterCreation6hto3dErrorBudgetBurn`

The following are the list of alerts that are associated with the <b>cluster deletion success rate</b> SLO:
- `FleetManagerAPIClusterDeletion30mto6hErrorBudgetBurn`
- `FleetManagerAPIClusterDeletion2hto1dErrorBudgetBurn`
- `FleetManagerAPIClusterDeletion6hto3dErrorBudgetBurn`

See [kas-OSD Fleet Manager-slos-availability-*](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/prometheusrules) prometheus rules in AppInterface to see how it was implemented.
