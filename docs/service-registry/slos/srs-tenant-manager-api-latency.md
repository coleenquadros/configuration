# Service Registry Service - Tenant Manager API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The Tenant Manager API is a critical component in the Managed Service Registry ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience. Both SRS-fleet-manager and Service Registry depend on its API to function properly.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different request duration value. We use the `rest_requests_seconds_bucket` histogram metric as the base of this SLO. 

This metric is shared with the Service Registry app, so it needs labels to filter the results to Service Registry, `job="tenant-manager",namespace="service-registry-stage"`. The implementation is also only including successsful responses, so the code label is added `,status_code_group!~"5xx"`.

## SLO Rationale
The 100ms for 90% of the requests and 1000ms for 99% of the requests objective was choosen based on observing the service running in stage.

Once additional data has been gathered, the SLO can be revaluated.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `SRSTenantManagerAPILatency30mto6hP99BudgetBurn`
- `SRSTenantManagerAPILatency2hto1dor6hto3dP99BudgetBurn`
- `SRSTenantManagerAPILatency30mto6hP90BudgetBurn`
- `SRSTenantManagerAPILatency2hto1dor6hto3dP90BudgetBurn`
  
