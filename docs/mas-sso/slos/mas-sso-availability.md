# MAS SSO  - Availability SLO/SLI

## SLI description

We are measuring the propoion of valid requests served successfully.




## SLI Rationale

MAS SSO being a critical component in the Managed Kafka ecosystem, it is expected to provide reliable responses and be available.
SLI codifies directly the service availability which indicates the health of the service. 


## Implementation details

We're measuring the 5xx response codes for the requests. Any 5xx response code means the MAS SSO service is not available. 
We count the number of API requests that do not have a 5xx status code and divide it by the total of all the API requests made. 
It is measured at the router using the `haproxy_backend_http_responses_total` metric.

## SLO Rationale

MAS SSO is expected to be available 99 percent of the time. The reason for such high availability requirements stem from the fact that
MAS SSO is the critical component in the Managed Kakfa ecosystem providing Authentican and Authorization services for end users and other services.
If MAS SSO is not available Managed Kafka service cannot be used.
The target is 99 percent of the requests do not receive a 5xx response from the service i.e. the service is available 99 percent of the time.
This aligns with the SLO of having 1 percent error budget for a 28 day window.

## Alerts

Following are the list of alerts that are associated with this SLO

- ManagedSSOAPI1hErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
- ManagedSSOAPI6hErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
- ManagedSSOAPI1dErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low
- ManagedSSOAPI3dErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low
  
