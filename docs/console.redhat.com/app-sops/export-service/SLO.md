# Export Service SLOs and SLIs

## Categories
The following categories will correspond to the SLIs and SLOs below.

1. HTTP Server
2. Database Engine
3. Pod Uptime

## SLIs
1. Availability - The proportion of successful requests, as measured from the load balancer metrics. Any HTTP status other than 500–599 is considered successful.
2. Latency - The proportion of sufficiently fast requests, as measured from the load balancer metrics. "Sufficiently fast” is defined as < 400 ms or < 850 ms. 
3. Thoroughput - The number of requests the service can handle in a given period. The service should be capable of supporting at least 100 requests per second (RPS)
4. Error rate - The percentage of requests that result in an error or failure. Any server HTTP status other than 4xx or 5xx is considered successful.

## SLOs

1. Availability `>95% success` (Any HTTP status other than 500–599 is considered successful.)
2. Latency `90% < 400ms` or `95% < 800ms`
3. Throughput `> 100 requests per second` or `95% of requests < 1000ms`
4. Error rate `> 95% success` (Any HTTP status other than 400–599 is considered successful.)

## Rationale
The given SLIs were determined based on the components belonging to the Export Service. The service lets customers define their report data, date ranges, and preferred format. Once processed and available, customers can download said reports. This requires a functioning internal and customer-facing API, RDS database, and kafka producer.

The SLO error budgets were determined by author definition.

## Error Budget
Error budgets are determined based on the SOP for each objective.

## Classifications and Caveats
* SLIs which are bound to prometheus metrics are laden to the uptime of the service. If the service goes down for any reason, the metrics we are able to gather will be skewed by down period.
