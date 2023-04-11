# Platform Changelog SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Database Engine
3. Pod Uptime

## SLIs
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Database engine success can be measured by the number of non-5xx API responses and the number of successfully processed payloads. Therefore, we can set our SLO for database engine success as the minimum SLO of the two.
3. Percentage of time that the pod remains in the UP state during the past 24h

## SLOs

1. `> 95%` of HTTP requests are non-5xx
2. `> 95%` as derived from HTTP Server
3. `> 95%` uptime

## Rationale
The given SLIs were determined based on the components belonging to the Platform Changelog Service. This service is an internal tool in development. The service gets information about git commits and openshift deployments through a mix of tools, but for the service, none of that can happen if the pods, database, and api are not functioning properly.

The SLO error budgets were determined by author definition.

## Error Budget
Error budgets are determined based on the SOP for each objective.

## Classifications and Caveats
* SLIs which are bound to prometheus metrics are laden to the uptime of the service. If the service goes down for any reason, the metrics we are able to gather will be skewed by down period.
