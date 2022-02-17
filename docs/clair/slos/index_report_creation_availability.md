# Clair v4 - Index report creation availability SLO/SLI

## SLI description
We want to measure the how often Clair's index report creation endpoint returns a non-succesful response.

## SLI rationale
In order to index new manifests from image tags uploaded to Quay.io and deliver security information to users in the UI an index report must first be requested and created. Failure to create this index report will result in added latency as the manifest will need to be reindexed.

## Implementation details

### Error Rate
We count the number of API requests that have a `5xx` status code and divide it by the total of all the API requests made. We use the metric `haproxy_server_http_responses_total` with the label filters `{exported_namespace="clair-production", route="clair-indexer-production"}` and the label `code` to calculate the error rate.
## SLO rationale
Clair is expected to respond successfully 98 percent of the time. There are cases when due to the unexpected nature of a manifest Clair will error but this should be less than 2 percent of the time. It is also possible that Clair will rate-limit clients should the number of concurrent indexer requests exceed a threshold, this also affects the availability of the service and should always be 0.
## Alerting
The following are the list of alerts that are associated with this SLO.

- `ClairIndexReportCreateAPI30mto6hErrorBudgetBurn`
- `ClairIndexReportCreateAPI2hto1dErrorBudgetBurn`
