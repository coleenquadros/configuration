# OSD Fleet Manager Reconcile loop - Success rate SLO/SLI

##<a name="SLI_description"></a> SLI description
We are measuring the proporition of reconcile loop that are successful by related status. The worker name is attached to each measure so the success reate can be clearly separated and identified. 

<a name="SLI_clusters_description"></a>Here are the measured statuses for Managment and Service Clusters:
1. The proportion of cluster `accepted` reconcile loop that are successful. This is the <b>accepted reconcile loop success rate</b>.
2. The proportion of cluster `account provisioned` reconcile loop that are successful. This is the <b>account provisioned reconcile loop success rate</b>.
3. The proportion of cluster `provisioning` reconcile loop that are successful. This is the <b>provisioning reconcile loop success rate</b>.
4. The proportion of `terraforming`/`provisioned` reconcile loop that are successful. This is the <b>terraforming reconcile loop success rate</b>.
5. The proportion of cluster `waiting for child` reconcile loop that are successful. This is the <b>waiting for child reconcile loop success rate</b>.
6. The proportion of cluster `ready` reconcile loop that are successful. This is the <b>ready reconcile loop success rate</b>.
7. The proportion of cluster `maintenance` reconcile loop that are successful. This is the <b>maintenance reconcile loop success rate</b>.
8. The proportion of cluster `deprovisioning` reconcile loop that are successful. This is the <b>deprovisioning reconcile loop success rate</b>.
9. The proportion of cluster `cleanup` reconcile loop that are successful. This is the <b>cleanup reconcile loop success rate</b>.


For the token renewal worker, there 2 SLIs:
1. The <b>OSDFM</b> token renewal success rate
2. The <b>OCM</b> token renewal success rate


Any other added worker shall have its own SLIs as well.

## SLI Rationale
The reconciles loops are the heart of the OSD Fleet Manager; it is them who are creating, terraforming, maintenaing the clusters and reacting to changes. It is expected from them to be successful, otherwise the clusters may either not be created at all, or be in a not useful/usable state.

## Implementation details
We count the loops which ends successfully and divide it by the total amount of loops executed by status.

## SLO Rationale
An OSD Fleet Manager should have a success rate of 99 percent for any reconcile loop.

Currently this SLO is being hurt by known erorrs in early steps, https://issues.redhat.com/browse/SDA-7422 should fix this.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. 

The following are the list of alerts that are associated with the <b>{reconcile loop name} reconcile loop success rate</b> SLO:
- `FleetManager{reconcile loop name}ReconcileLoop30mto6hErrorBudgetBurn`
- `FleetManager{reconcile loop name}ReconcileLoop2hto1dErrorBudgetBurn`
- `FleetManager{reconcile loop name}ReconcileLoop6hto3dErrorBudgetBurn`
With {reconcile loop name} being the name mentionned in the [SLI Description for cluster workers](#SLI_clusters_description)

The following are the list of alerts that are associated with the <b>token renewal success rate</b> SLO:
- `FleetManagerOSDFMTokenRenewalReconcileLoop30mto6hErrorBudgetBurn`
- `FleetManagerOSDFMTokenRenewalReconcileLoop2hto1dErrorBudgetBurn`
- `FleetManagerOSDFMTokenRenewalReconcileLoop6hto3dErrorBudgetBurn`
- `FleetManagerOCMTokenRenewalReconcileLoop30mto6hErrorBudgetBurn`
- `FleetManagerOCMTokenRenewalReconcileLoop2hto1dErrorBudgetBurn`
- `FleetManagerOCMTokenRenewalReconcileLoop6hto3dErrorBudgetBurn`
