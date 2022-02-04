# Clair v4 - Index report creation latency SLO/SLI

## SLI description
We want to measure the response times of Clair when creating Index Reports.

## SLI rationale
In order to index new manifests from image tags uploaded to Quay.io and deliver security information to users in the UI an index report must first be requested and created. This is already a latent request but we need to measure if latency is exceeded expected bounds in order ensure we are processing all new tags uploaded to Quay.

## Implementation details
We count the percentage of requests that exceed a certain latency over different time windows. We use the metric `clair_http_indexerv1_request_duration_seconds_bucket` with the labels `{handler="/indexer/api/v1/index_report",method="post",code="201"}` and the `le` label to specify the bucket.

## SLO rationale
Clair is expected to respond to 70% of indexing requests in under 10 seconds, this number is heavily dependent on the traffic it receives (i.e. novel manifests vs previously indexed manifests), but it gives a good idea of if the service is running in a healthy state or if there may be bottlenecks slowing indexing down.

## Alerting
 The following are the list of alerts that are associated with this SLO.

- `ClairIndexReportCreateAPI30mto6hLatencyP70BudgetBurn`
