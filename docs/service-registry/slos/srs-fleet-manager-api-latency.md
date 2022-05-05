# Service Registry Service - Fleet Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The SRS-fleet-manager API is a critical component in the Managed Service Registry ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different request duration value. We use the `rest_requests_seconds_bucket` histogram metric as the base of this SLO.

This metric is produced by all apicurio applications, so it needs labels to filter the results for srs-fleet-manager, `job="srs-fleet-manager-metrics",namespace="service-registry-stage"`. The implementation is also only including successful responses, so the code label is added `,status_code_group!~"5xx"`.

## SLO Rationale
The 100ms for 90% of the requests and 1000ms for 99% of the requests objective was chosen based on observing the service running in stage.

Once additional data has been gathered, the SLO can be re-evaluated.

## Alerts
All alerts are multi-window, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `SRSFleetManagerAPILatency30mto6hP99BudgetBurn`
- `SRSFleetManagerAPILatency2hto1dor6hto3dP99BudgetBurn`
- `SRSFleetManagerAPILatency30mto6hP90BudgetBurn`
- `SRSFleetManagerAPILatency2hto1dor6hto3dP90BudgetBurn`
  
