# Advisor SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Payload Processing
3. Pod Uptime

## SLIs
1. Percentage of successful (non-5xx) HTTP requests made to the API in the past 24 hours
2. Percentage of correctly-formatted messages ingested from Kafka, which are successfully processed in the past 24 hours.
3. Percentage of time that the pod remains in the UP state during the past 24h

## SLOs

1. `> 95%` of HTTP requests are non-5xx
2. `> 95%` of consumed messages are processed successfully based on SLI success criteria
3. `> 95%` uptime

## Rationale
The given SLIs were determined based on the necessary components of the Advisor API and Advisor Service. The main function of the API is to serve HTTP requests. Database connection and successful operation, therefore, is paramount to the operability of the API on the whole. The main function of the Service is to process results from the shared engine. Database connection and successful operation, therefore, is paramount to the operability of the service on the whole.

## Error Budget
Error budgets are determined based on the SOP for each objective.
