# Kafka Service Fleet Manager - Kafka Lifecycle Correctness SLO/SLI

## SLI description
We are measuring the proportion of Kafka instance lifecycle operations (creation and deletion) that were successful.

## SLI Rationale
Ensuring that a Kafka instance has been created or deleted sucessfully is integral to ensuring good user experience. 

## Implementation details
There are two SLIs backing this SLO. Both use the same metric with a different `operation` label for differentiating between `create` and `delete`. This SLI uses the `kas_fleet_manager_kafka_operations_success_count` and `kas_fleet_manager_kafka_operations_total_count` metrics.

The implementation includes the following labels `job="kas-fleet-manager-metrics",namespace="managed-services-production"` for the counter metric.

The `kas_fleet_manager_kafka_operations_success_count` counter is incremented for `create` when the Kafka instance changes to a ready state which is reported from the `fleetshard-operator` in the data plane.

The `kas_fleet_manager_kafka_operations_success_count` counter is incremented for `delete` when the Kafka instance has been soft deleted from the database which occurs after all associated resources and dependencies have been removed.

The `kas_fleet_manager_kafka_operations_total_count` counter is incremented in both scenarios above and also when the Kafka instance changes to a failed state which is reported from the `fleetshard-operator` in the data plane.

## SLO Rationale
Kafka instance creations and deletions are expected to be succcessful 99 percent of the time. This has been proven while observing the SLO in production and during scale testing.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `KasFleetManagerKafkaCreationSuccess30mto6hBudgetBurn`
- `KasFleetManagerKafkaCreationSuccess2hto1dBudgetBurn`
- `KasFleetManagerKafkaCreationSuccess6hto3dBudgetBurn`
- `KasFleetManagerKafkaDeleteSuccess30mto6hBudgetBurn`
- `KasFleetManagerKafkaDeleteSuccess2hto1dBudgetBurn`
- `KasFleetManagerKafkaDeleteSuccess6hto3dBudgetBurn`
  
