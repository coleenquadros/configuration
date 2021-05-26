# MAS SSO - Latency SLI/SLO

## SLI description

We are measuring the proportion of all the requests that were served beyond a threshold value. 

## SLI Rationale

MAS SSO being a critical component in the Managed Kafka ecosystem, it is expected to provide reliable responses within a stipulated time.
SLI codifies directly the service latency which indicates the health of the service. 

## Implementation details

We count the number of API requests that have a request duration of less than or equal to 1000 milliseconds divided 
by the total number of requests that were received during the given time window. It is measured using the following metrics at keycloak service
- `keycloak_request_duration_bucket` to get the requests that are less than or equal to 1000 milliseconds
- `keycloak_request_duration_count` to get the total number of requests 

Currently we cannot filter out responses based on status codes in these metrics. The SLO in the future should only consider valid responses (not 5xx status codes). 
There is a JIRA issue that tracks the same: https://issues.redhat.com/browse/MGDSTRM-3724 

## SLO Rationale

MAS SSO is expected to serve 99 percent of the requests within 1000 milliseconds. The reason for such strict latency requirements stem from the fact that
MAS SSO is the critical component in the Managed Kakfa ecosystem providing Authentican and Authorization services for end users and other services. 
Any increase in latency would have a cascading effect on the Managed Kafka user experience. 
The target is the response time for 99 percent of the requests should be less than 1000 milliseconds. 
This aligns with the SLO of having 1 percent error budget for a 28 day window.

## Alerts

Following are the list of alerts that are associated with this SLO

- MasSSOLatency5mto1hrBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
* MasSSOLatency30to6hrBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
- MasSSOLatency2hto1dBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low
- MasSSOLatency6hto3dBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low

