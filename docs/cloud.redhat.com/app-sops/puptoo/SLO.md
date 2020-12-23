# Puptoo SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. Payload Processing
2. Pod Uptime
3. Kafka Message Processing

## SLIs

1. Processing: sum(increase(puptoo_successful_extractions_total[24h])) / sum(increase(puptoo_extractions_total[24h])) < .95
2. Uptime: avg(avg_over_time(up{service="puptoo-processor"}[24h])) < .98
3. Message Consumption: sum(increase(puptoo_messages_consumed_failure_total[24h])) / sum(increase(puptoo_messages_consumed_total[24h])) < .05

## SLOs

1. `> 95%` of payloads are processed successfully through the system
2. `> 98%` uptime
3. `> 95%` of messages successfully consumed from kafka

## Rationale
The given SLIs were determined based on the necessary functions of puptoo. Puptoo is heavily reliant on kafka as its main ingress and egress system. If either kafka, or the internal processing of puptoo begins to show significant errors, it can be assumed that customers are being impacted.

## Error Budget
Error budgets are determined based on the SOP for each objective.
