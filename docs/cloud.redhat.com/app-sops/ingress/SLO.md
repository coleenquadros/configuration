# Ingress SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Payload Processing
3. Pod Uptime

## SLIs
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Percentage of responses served withint 2 seconds in the past 24 hours
3. Percentage of time that the pod remains in the UP state during the past 24 hours
4. Percentage of messages published to kafka in the past 24 hours
5. Percentage of cloud storage errors in the past 24 hours

## SLOs

1. `> 95%` of HTTP requests are non-5xx
2. `> 95%` of HTTP requests are served within 2 seconds
3. `> 98%` uptime
4. `> 95%` of messages are placed onto kafka successfully
5. `> 95%` of payloads are successfully stored

## Rationale
The given SLIs were determined based on the necessary components of the Ingress API. The main function of the API is to serve HTTP requests. Beyond that, the service places data on cloud storage (S3) and messages are produced to Kafka. Each of these components are paramount to the operability of the service and the platform.

## Error Budget
Error budgets are determined based on the SOP for each objective.
