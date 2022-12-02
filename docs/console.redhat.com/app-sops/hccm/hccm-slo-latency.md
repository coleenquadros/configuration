# Cost Management API Latency

## SLI description

We're measuring the proportion of our API response that take longer than two seconds. As the user interface or customer requests for data using the API we intend to have ninety percent or higher proportion of responses take less than two seconds over a month (28 day period).

Note: The metric used for this calculation includes all requests, included error requests (5xx), there is no ability to filter the latency measurement by status code.

## SLI Rationale

The main purpose of Cost Management is to provide customers cost data breakdowns for cloud costs or hybrid cloud deployments of OpenShift. This SLI codifies directly the user experience that successful and fast responses of cost data indicates a sign of health. While depending on the window of time and complexity of the filter the customer is requesting data for can affect the response time we have built our API and index & partitioned our data in order to have performant and quick responses.

## Implementation details

We use the `api_3scale_gateway_api_time_bucket` metric and `api_3scale_gateway_api_time_count` metric as the base for this SLO.

Our API server is exposed through the 3Scale service deployed on the console.redhat.com OpenShift cluster. All API traffic is routed through this service and it captures all API requests including a total count per application and a bucketed historgram for the API response times. Leveraging this proportion we are able to define our SLO.

## SLO Rationale

We acknowledge that a 10% latency rate over a month may seem high but there are several dependent components including 3Scale, Red Hat SSO, the Entitlements Service, and Akamai which are all in the network path for our API service and could add additional time to the request which could result in a request timing out. Additionally some enterprise customer accounts have many cloud accounts and clusters and as the volume of the data and the window of time the data is requested over increase so can the length of time for a request. We believe the greater than 90% API response completing in under two seconds models current expectations of customers to date and is far better than some industry competitors.

## Alerts

An alert for this availabilty check can be found in the following prometheus rules file (rule: App-koku-api-latency):
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/hccm-prod/hccm.prometheusrules.yaml
