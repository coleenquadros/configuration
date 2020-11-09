# Puptoo SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. Pod Uptime
2. Cloud Storage Copy Operations
3. Kafka Message Processing

## SLIs

1. Uptime: avg(avg_over_time(up{service="storage-broker"}[24h])) > .98
2. Copy Operations: sum(increase(storage_broker_object_copy_error_count_total[24h])) / sum(increase(storage_broker_object_copy_success_count_total[24h])) + sum(increase(storage_broker_object_copy_error_count_total[24h])) 
3. Percentage of messages produced to kafka in the past 24 hours
4. Percentage of messages consumed from kafka in the past 24 hours

## SLOs

1. `> 98%` uptime
2. `> 95%` of S3 operations are successful
3. `> 95%` of messages successfully produced to kafka
4. `> 95%` of messages successfully consumed from kafka

## Rationale
The given SLIs were determined based on the necessary functions of storage-broker. Storage-broker is heavily reliant on kafka as its main ingress and egress system. If either kafka, or the copying of files to cloud storage has a high failure rate, it should be investigated.

## Error Budget
Error budgets are determined based on the SOP for each objective.
