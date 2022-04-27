# Service Registry Service - Service Registry API - Latency SLO/SLI

## SLI description
We are measuring the proportion of requests served faster than a certain threshold.

## SLI Rationale
The Service Registry API is a critical component in the Managed Service Registry ecosystem, it is expected to provide sufficiently fast responses to ensure good user experience.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different request duration value. We use the `rest_requests_seconds_bucket` histogram metric as the base of this SLO. 

This metric is shared with the Tenant Manager component, so it needs labels to filter the results to Service Registry, `job="apicurio-registry",namespace="service-registry-stage"`. The implementation is also only including successful responses, so the code label is added `,status_code_group!~"5xx"`.

## SLO Rationale
The base objective of 1000ms for 99% of the requests was chosen based on observing the service running in stage. 

There are additional SLOs for each of the basic Service Registry API operations: read, write and search. Their specific objectives have been chosen based on the importance of those operations for user applications, in terms of how often are the operations used and how a slow execution of the given operation affects user experience. The current objectives are as follows:

- All: 99% of requests < 1000ms
- Read: 99% of requests < 250ms
- Write: 99% of requests < 1000ms
- Search: 99% of requests < 1000ms

Once additional data has been gathered, the SLO can be re-evaluated.

## Alerts

All alerts are multi-window, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO:

Data Plane Latency (All)
- `SRSServiceRegistryAPIAllLatency30mto6hP99BudgetBurn`
- `SRSServiceRegistryAPIAllLatency2hto1dor6hto3dP99BudgetBurn`

Data Plane Latency (Read)  
- `SRSServiceRegistryAPIReadLatency30mto6hP99BudgetBurn`
- `SRSServiceRegistryAPIReadLatency2hto1dor6hto3dP99BudgetBurn`

Data Plane Latency (Write)
- `SRSServiceRegistryAPIWriteLatency30mto6hP99BudgetBurn`
- `SRSServiceRegistryAPIWriteLatency2hto1dor6hto3dP99BudgetBurn`

Data Plane Latency (Search)
- `SRSServiceRegistryAPISearchLatency30mto6hP99BudgetBurn`
- `SRSServiceRegistryAPISearchLatency2hto1dor6hto3dP99BudgetBurn`
