# Service Registry Service Fleet Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The SRS-fleet-manager API is a critical component in the Managed Service Registry ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different request duration value. We use the `http_server_requests_seconds_bucket` histogram metric as the base of this SLO. 

This metric could be shared with any Quarkus application using Micrometer, so it needs labels for srs-fleet-manager to filter the results to srs-fleet-manager, `job="srs-fleet-manager-metrics",namespace="service-registry-stage"`. The implementation is also only including successsful responses, so the code label is added `,status!~"5.."`.

The p99 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 1000ms divided by the count of all of API HTTP requests.

The p90 SLI implementation is the count of successful API HTTP requests with a duration that is less than or equal to 100ms divided by the count of all of API HTTP requests.

## SLO Rationale
The p90 of 100ms and p99 of 1000ms was choosen based on observing the service running in stage.

Once additional data has been gathered, the SLO can be revaluated.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `SRSFleetManagerAPILatency30mto6hP99BudgetBurn`
- `SRSFleetManagerAPILatency2hto1dor6hto3dP99BudgetBurn`
- `SRSFleetManagerAPILatency30mto6hP90BudgetBurn`
- `SRSFleetManagerAPILatency2hto1dor6hto3dP90BudgetBurn`
  
