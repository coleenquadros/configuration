# Puptoo SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. Pod Uptime
2. Cloud Storage Copy Operations

## SLIs

1. Uptime: avg(avg_over_time(up{service="storage-broker"}[24h])) > .98
2. Copy Operations: sum(increase(storage_broker_object_copy_error_count_total[24h])) / sum(increase(storage_broker_object_copy_success_count_total[24h])) + sum(increase(storage_broker_object_copy_error_count_total[24h])) > .05

## SLOs

1. `> 98%` uptime
2. `> 95%` of S3 operations are successful

## Rationale
The given SLIs were determined based on the necessdary functions of storage-broker.

## Error Budget
Error budgets are determined based on the SOP for each objective.
