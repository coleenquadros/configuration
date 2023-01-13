# Fleet Manager API - Saturation Level SLO/SLI

## SLI description
We are measuring the saturation level of the Management Clusters (MC) composing the fleet by region.

## SLI Rationale
The Fleet Manager is managing a fleet of MC and scales up if a high saturation threshold (amount of Hosted Cluster (HC) on the MC) is reached. 
This high saturation threshold is designed to avoid reaching the max desired amount of HC. 
If the max desired amount of HC is reached accross the Service Cluster it means there is an issue and the user may be impacted when requested the allocation of a new HC as no MC will be available.

## Implementation details
To measure this SLI, we count the amount of HC in each Service Cluster and we compute its remaining HC capacity. Both the count of HC by Service Cluster, the max desired HC by MC, the amount of valid MC (ie: usable MC for HC allocation) by Service Cluster and the remaning HC capacity are made available.

## SLO Rationale
The remaning HC capacity shall always be greater than 0 so new HC allocation may be fulfilled. 
The count of HC by Service Cluster shall always be lower than or  equal to (the amount of valid MC * the max desired HC by MC).
The first one is the corollary of the second one.
As we have a high saturation level threshold of 80% by default, we consider that the SLI is not fulfilled when we reach a 90% saturation level.

## Alerts

> NOTE this section contains references to Red Hat internal components

All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `FleetManagerServiceClusterCapacity<OCM Cluster ID>30mto6hP99BudgetBurn`
- `FleetManagerServiceClusterCapacity<OCM Cluster ID>2hto1dor6hto3dP99BudgetBurn`
- `FleetManagerServiceClusterCapacity<OCM Cluster ID>30mto6hP90BudgetBurn`
- `FleetManagerServiceClusterCapacity<OCM Cluster ID>2hto1dor6hto3dP90BudgetBurn`
  
See [kas-fleet-manager-slos-latency-*](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/prometheusrules) prometheus rules in AppInterface to see how it was implemented.
