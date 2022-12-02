# Cost Management API Availability

## SLI description

We're measuring the error rate of our API response codes. As the user interface or customer requests for data using the API we intend to have ninety percent or higher successful responses over a month (28 day period). Essentially minimizing 500-599 error code responses which indicate a problem with the API server not properly providing data.

## SLI Rationale

The main purpose of Cost Management is to provide customers cost data breakdowns for cloud costs or hybrid cloud deployments of OpenShift. This SLI codifies directly the user experience that successful responses of cost data indicates a sign of health.

## Implementation details

We use the `api_3scale_gateway_api_status` metric as the base for this SLO.

Our API server is exposed through the 3Scale service deployed on the console.redhat.com OpenShift cluster. All API traffic is routed through this service and it captures all API response codes including service gateway timeouts for requests that take longer than the maximum 30 second allowed period.

## SLO Rationale

We acknowledge that a 10% error rate over a month may seem high but there are several dependent components including 3Scale, Red Hat SSO, the Entitlements Service, and Akamai which are all in the network path for our API service and could lead to errors unrelated to our API server directly or which could intermittently add additional time to the request which could result in a request timing out. Additionally some errors could occur due to pod rebalancing during cluster upgrade which happen frequently throughout the month. We believe the greater than 90% API availability models current expectations of customers to date.

## Alerts

An alert for this availabilty check can be found in the following prometheus rules file (rule: App-koku-5xx-In-hccm):
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/hccm-prod/hccm.prometheusrules.yaml
