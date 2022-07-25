# ACS Fleet Manager - ACS Central creation Latency SLO/SLI

## SLI description
We are measuring the creation time of all successful ACS Central instances creation, starting from the time an ACS Central creation request is received until the ACS Central changes to a `ready` state.

## SLI Rationale
The time to readiness of a new ACS Central instance is integral to the user experience.

## Implementation details
The `fleet_manager_worker_dinosaur_duration_bucket` histogram metric is used for this SLO. 

The implementation includes the following labels `job="fleet-manager-metrics", namespace="acs-fleet-manager",jobType="create"` for the histogram metric.

The ACS Central creation duration is added to the `fleet_manager_worker_dinosaur_duration_bucket` metric when the ACS Central instance changes to a ready state which is reported from the `ACS fleetshard-sync` in the data plane.

The p90 SLI implementation is the count of successful ACS Central creations with a duration that is less than or equal to 90 minutes divided by the count of all successful ACS Central creations.

## SLO Rationale
The average ACS Central creation latency should be under 5 minutes. 
It is based on manual tests and experience about provision ACS Central without ACS Fleet Manager.
Thus, SLI has a huge margin.
Once additional data has been gathered in production, the SLO can be reevaluated and reduced and most split into p90 and p99 percentiles.

## Alerts

TODO
  
