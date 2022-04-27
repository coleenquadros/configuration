# Service Registry Service - Service Registry API - Availability SLO/SLI

## SLI description
We are measuring the proportion of requests that resulted in a successful response from the endpoints external users can interact with.

## SLI Rationale
The Service Registry API is a critical component in the Managed Service Registry ecosystem, it's implemented by the components Service Registry (also known as Apicurio Registry). It is expected be available and responding successfully to requests.

## Implementation details
We count the number of API requests that do not have a `5xx` status code and divide it by the total of all the API requests made. 
~~It is measured at the router using the `haproxy_backend_http_responses_total` metric.~~

## SLO Rationale
Service Registry is expected to be available 99 percent of the time. There are additional SLOs for each of the basic Service Registry API operations: read, write and search. Their specific objectives have been chosen based on the importance of those operations for user applications, in terms of how often are the operations used and how a slow execution of the given operation affects user experience. The current objectives are as follows:

- All: 99% success
- Read: 99.95% success
- Write: 99% success
- Search: 99% success

## Alerts
All alerts are multi-window, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO:

Data Plane Availability (All)
- `SRSServiceRegistryAPIAll30mto6hErrorBudgetBurn`
- `SRSServiceRegistryAPIAll2hto1dErrorBudgetBurn`
- `SRSServiceRegistryAPIAll6hto3dErrorBudgetBurn`

Data Plane Availability (Read)
- `SRSServiceRegistryAPIRead30mto6hErrorBudgetBurn`
- `SRSServiceRegistryAPIRead2hto1dErrorBudgetBurn`
- `SRSServiceRegistryAPIRead6hto3dErrorBudgetBurn`

Data Plane Availability (Write)
- `SRSServiceRegistryAPIWrite30mto6hErrorBudgetBurn`
- `SRSServiceRegistryAPIWrite2hto1dErrorBudgetBurn`
- `SRSServiceRegistryAPIWrite6hto3dErrorBudgetBurn`

Data Plane Availability (Search)
- `SRSServiceRegistryAPISearch30mto6hErrorBudgetBurn`
- `SRSServiceRegistryAPISearch2hto1dErrorBudgetBurn`
- `SRSServiceRegistryAPISearch6hto3dErrorBudgetBurn`

  
