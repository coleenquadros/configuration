# Fleet Manager API - Added Latency SLO/SLI

## SLI description
We are measuring the latency added by Fleet Manager in the provisionning workflow. Not yet implemented

## SLI Rationale
The Fleet-manager adds latency when performing actions in the Hosted Cluster provisionning workflow. The goal of this SLI is to measure this added latency that will allow internal users and customers to know how fast the process is.

## Implementation details
To measure this SLI, we measure the time between the reception of the request and its completion. This time is mainly influenced by the Management Cluster (MC) scale up if high saturation threshold is reached and by the needs to scale up of nodes inside the MC to host requested Hosted Cluster.

## SLO Rationale
This SLO is not currently implemented, see https://issues.redhat.com/browse/SDA-7423

## Alerts

> NOTE this section contains references to Red Hat internal components

All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `FleetManagerAddedLatency30mto6hP99BudgetBurn`
- `FleetManagerAddedLatency2hto1dor6hto3dP99BudgetBurn`
- `FleetManagerAddedLatency30mto6hP90BudgetBurn`
- `FleetManagerAddedLatency2hto1dor6hto3dP90BudgetBurn`


