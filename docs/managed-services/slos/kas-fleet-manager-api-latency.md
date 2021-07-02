# Kafka Service Fleet Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The Kas-fleet-manager API is a critical component in the Managed Kafka ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different request duration value. We use the `api_inbound_request_duration_bucket` histogram metric as the base of this SLO. 

Since this metric is shared with the OCM services, it needs labels for kas-fleet-manager to filter the results to kas-fleet-manager, `job="kas-fleet-manager-metrics",namespace="managed-services-production"`. The implementation is also only including successsful responses, so the code label is added `,code!~"5.."`.

The p99 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 1000ms divided by the count of all of API HTTP requests.

The p90 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 100ms divided by the count of all of API HTTP requests.

## SLO Rationale
The p90 of 100ms and p99 of 1000ms was choosen based on observing the service running in production over a long period of time and from running API performance tests which verified the SLO was met while hitting our global rate limiting of 600 req/s using limitador.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `KasFleetManagerAPILatency30mto6hP99BudgetBurn`
- `KasFleetManagerAPILatency2hto1dor6hto3dP99BudgetBurn`
- `KasFleetManagerAPILatency30mto6hP90BudgetBurn`
- `KasFleetManagerAPILatency2hto1dor6hto3dP90BudgetBurn`
  
