# Kafka Service Fleet Manager - Kafka Provisioning Latency SLO/SLI

## SLI description
We are measuring the creation time of all successful Kafka provisioning, starting from the time a Kafka creation request is receieved until the Kafka instance changes to a `ready` state.

## SLI Rationale
The time to readiness of a new Kafka instance is integral to the user experience of our Managed Kafka service.

## Implementation details
There are two SLIs backing these two SLOs. Both use the same metric with a different duration value for the p90 and p99 of Kafka creation duration. We use the `kas_fleet_manager_worker_kafka_duration_bucket` histogram metric as the base of this SLO. 

The implementation includes the following labels `job="kas-fleet-manager-metrics", namespace="managed-services-production",jobType="kafka_create"` for the histogram metric.

The Kafka creation duration is added to the `kas_fleet_manager_worker_kafka_duration_bucket` metric when the Kafka instance changes to a ready state which is reported from the `fleetshard-operator` in the data plane.

The p99 SLI implementation is the count of successful Kafka creations with a duration that is less than or equal to 30 minutes divided by the count of all successful Kafka creations.

The p90 SLI implementation is the count of successful Kafka creations with a duration that is less than or equal to 15 minutes divided by the count of all successful Kafka creations.

## SLO Rationale
The average Kafka creation latency in production is 5 minutes. The reason for the significantly higher SLO of p90 at 15m and p99 at 30m is due to observed creation latency increase while scale testing Managed Kafka at 1500 created Kafkas within a short period of time.

Once additional data has been gathered in production, the SLO can be revaluated and reduced.

## Alerts
All alerts are multiwindow, multi-burn-rate alerts. The following are the list of alerts that are associated with this SLO.

- `KasFleetManagerKafkaOperationsLatency30mto6hP90BudgetBurn`
- `KasFleetManagerKafkaOperationsLatency2hto1dor6hto3dP90BudgetBurn`
- `KasFleetManagerKafkaOperationsLatency30mto6hP99BudgetBurn`
- `KasFleetManagerKafkaOperationsLatency2hto1dor6hto3dP99BudgetBurn`
  
