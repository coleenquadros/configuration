# Service Registry Service - Fleet Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The SRS-fleet-manager API is a critical component in the Managed Service Registry ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different request duration value. We use the `http_server_requests_seconds_bucket` histogram metric as the base of this SLO. 

This metric could be shared with any Quarkus application using Micrometer, so it needs labels for srs-fleet-manager to filter the results to srs-fleet-manager, `job="srs-fleet-manager-metrics",namespace="service-registry-stage"`. The implementation is also only including successsful responses, so the code label is added `,status!~"5.."`.

## SLO Rationale
The 100ms for 90% of the requests and 1000ms for 99% of the requests objective was choosen based on observing the service running in stage.

Once additional data has been gathered, the SLO can be revaluated.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `SRSFleetManagerAPILatency30mto6hP99BudgetBurn`
- `SRSFleetManagerAPILatency2hto1dor6hto3dP99BudgetBurn`
- `SRSFleetManagerAPILatency30mto6hP90BudgetBurn`
- `SRSFleetManagerAPILatency2hto1dor6hto3dP90BudgetBurn`
  
