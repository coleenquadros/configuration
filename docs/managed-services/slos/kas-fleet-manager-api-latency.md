# Kafka Service Fleet Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The Kas-fleet-manager API is a critical component in the Managed Kafka ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
For the purposes of assessing service performance, the API service is divided into two different sections;
  * Overall API (excluding /metrics/federate endpoint)
  * /metrics/federate endpoint only (i.e., `/api/kafkas_mgmt/v1/kafkas/{id}/metrics/federate`)

This distinction into separate service subsections is due to the large difference in performance between the /metrics/federate endpoint and the rest of the service.

There are two SLIs backing each of the SLOs. Both use the same metric with a different request duration value. We use the `api_inbound_request_duration_bucket` histogram metric as the base of each SLO. 

Since this metric is shared with the OCM services, it needs labels for kas-fleet-manager to filter the results to kas-fleet-manager, `job="kas-fleet-manager-metrics",namespace="managed-services-production"`. The implementation is also only including successful responses, so the code label is added `,code!~"5.."`.
### Overall API
For assessing the service excluding the /metrics/federate endpoint, the label `path!~".*federate$"` is added to the relevant expressions.

The p99 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 1000ms divided by the count of all of API HTTP requests excluding the /metrics/federate endpoint.

The p90 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 100ms divided by the count of all of API HTTP requests excluding the /metrics/federate endpoint.
### /metrics/federate endpoint

For assessing the /metrics/federate endpoint only, the label `path=~"/api/kafkas_mgmt/v1/kafkas/-/metrics/federate"` is added to the relevant expressions. 

The p99 SLI implementation is the count of successful HTTP requests to the /metrics/federate endpoint with a duration that is less than or equal to 5s divided by the count of all of HTTP requests to the /metrics/federate endpoint.

The p90 SLI implementation is the count of successful HTTP requests to the /metrics/federate endpoint with a duration that is less than or equal to 2s divided by the count of all of HTTP requests to the /metrics/federate endpoint.

## SLO Rationale
### Overall API
The p90 of 100ms and p99 of 1000ms were chosen based on observing the service running in production over a long period of time and from running API performance tests which verified the SLO was met while hitting our global rate limiting of 600 req/s using limitador.

### /metrics/federate endpoint
From observing the /metrics/federate endpoint performance in production over a long period of time, it was decided that a more suitable SLO was required for the /metrics/federate endpoint that was separate to the rest of the service. As a result, the SLO for this endpoint was modified to p90 of 2s and p99 of 5s.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with these SLOs.

### Overall API
- `KasFleetManagerAPILatency30mto6hP99BudgetBurn`
- `KasFleetManagerAPILatency2hto1dor6hto3dP99BudgetBurn`
- `KasFleetManagerAPILatency30mto6hP90BudgetBurn`
- `KasFleetManagerAPILatency2hto1dor6hto3dP90BudgetBurn`

### /metrics/federate endpoint
- `KasFleetManagerMetricsFederateLatency30mto6hP99BudgetBurn`
- `KasFleetManagerMetricsFederateLatency2hto1dor6hto3dP99BudgetBurn`
- `KasFleetManagerMetricsFederateLatency30mto6hP90BudgetBurn`
- `KasFleetManagerMetricsFederateLatency2hto1dor6hto3dP90BudgetBurn`
