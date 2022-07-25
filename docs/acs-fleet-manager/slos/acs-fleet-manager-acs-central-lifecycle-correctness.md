# ACS Fleet Manager - ACS Central Lifecycle Correctness SLO/SLI

## SLI description
We are measuring the proportion of ACS Central instance lifecycle operations (creation and deletion) that were successful.

## SLI Rationale
Ensuring that an ACS Central instance has been created or deleted successfully is integral to ensuring good user experience. 

## Implementation details
There are two SLIs backing this SLO. Both use the same metric with a different `operation` label for differentiating between `create` and `delete`. 
This SLI uses the `fleet_manager_dinosaur_operations_success_count` and `fleet_manager_dinosaur_operations_total_count` metrics.

The implementation includes the following labels `job="fleet-manager-metrics",namespace="acs-fleet-manager-<stage|prodution>"` for the counter metric.

The `fleet_manager_dinosaur_operations_success_count{namespace="acs-fleet-manager-<stage|prodution>",operation="create"}` counter is incremented for `create` when the ACS Central instance changes to a ready state which is reported from the `ACS fleetshard-sync` in the data plane.

The `fleet_manager_dinosaur_operations_success_count{namespace="acs-fleet-manager-<stage|prodution>",operation="delete"}` counter is incremented for `delete` when the ACS Central instance has been softly deleted from the database which occurs after all associated resources and dependencies have been removed.

The `fleet_manager_dinosaur_operations_total_count{namespace="acs-fleet-manager-<stage|prodution>"}` counter is incremented in both scenarios above and also when the ACS Central changes to a failed state which is reported from the `ACS fleetshard-sync` in the data plane.

## SLO Rationale
The ACS Central creations and deletions are expected to be successful 95 percent of the time. 
This is a low bar estimation and could be adjusted once the service is running on production for a reasonable time.

## Alerts

TODO
  
