# Performance Testing

## Deployment

1. Currently the Cost Management service deployed to the OpenShift Performance cluster using Clowder
2. Cost Mgmt service uses one postgres instance & one S3 bucket that is deployed using perf-aws-account in AWS.
3. All configuration changes are managed through app-interface

## Performance Testing

The following breaks down the performance testing.

### Scenarios

1. As many concurrent users as possible to overview
2. Constant rate of 5-50 concurrent users per second to Overview
3. As many concurrent users as possible to details pages
4. Constant rate of 5-50 concurrent users per second to details pages
5. Add as many sources as possible in x time
6. Constant rate of 5-50 sources per second 
7. Ingest as many sources as possible
8. Constant rate of 5-50 sources ingests per second
9. Add/ingest a large source/csv’s

### Tools

1. IQE plugin to create sources
2. Nise tool to generate cost and usage or metric data
3. Locust to test API endpoint at volume

## How to rerun the Performance Testing

[Cost Management Performance Test Plan](https://docs.google.com/document/d/17sWmckckzALCPwSQabpVQv_9Ks0L_96r9bbNs1Cy4Ps/edit?usp=sharing)
