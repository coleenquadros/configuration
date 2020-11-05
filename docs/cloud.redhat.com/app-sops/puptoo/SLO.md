# Puptoo SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. Payload Processing
2. Pod Uptime
3. Kafka Message Processing

## SLIs

1. Percentage of payloads successfully processed in the past 24 hours
2. Percentage of time that the pod remains in the UP stage during the past 24 hours
3. Percentage of messages produced to kafka in the past 24 hours
4. Percentage of messages consumed from kafka in the past 24 hours

## SLOs

1. `> 95%` of payloads are processed successfully through the system
2. `> 95%` uptime
3. `> 95%` of messages successfully produced to kafka
4. `> 95%` of messages successfully consumed from kafka

## Rationale
The given SLIs were determined based on the necessary functions of puptoo. Puptoo is heavily reliant on kafka as its main ingress and egress system. If either kafka, or the internal processing of puptoo begins to show significant errors, it can be assumed that customers are being impacted.

## Error Budget
Error budgets are determined based on the SOP for each objective.
