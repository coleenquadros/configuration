# Quay.io Action Logs
Quay.io's action logs are stored and queried from an Elasticsearch cluster managed by Elastic.
Quay.io's Elasticsearch deployment makes use of a hot-warm architecture for audit logs storage.
These logs are indexed by day.
- Two High IO nodes are used to ingest new documents, and are where new indices are created
- Two High Storage nodes are used for longer term storage of older indices (10 days) until they eventually
  get archived to S3 (30 days)

We also define allocation rules limiting which nodes can get assigned new indices.
- New indices can only be created on the High IO nodes.
- Older indices are moved to High Storage nodes after a period of time

Based on the cluster's settings and these allocation rules, the indices can only have 1 replica,
and a node going down means a replica will not be able to get allocated.


## Elasticsearch
The console for managing the Elastic account and clusters can be found at:
- [https://cloud.elastic.co/deployments](https://cloud.elastic.co/deployments)

The cluster name used for Quay.io: `quay-prod-logenry`
The production cluster's Kibana dashboard can be found at:
- [Production cluster's Kibana instance](https://37fecf6d2f6d4040bd2d4d24ae05af73.us-east-1.aws.found.io:9243/app/kibana)


### Monitoring
Metrics from the production cluster are sent in a separate Elasticsearch cluster in the same account. This cluster stores the time series data and allows vizualization in Grafana, and sending alerts to slack on events. e.g Cluster statuses, disk space.

The monitoring cluster used: `monitoring-cluster`
The monitoring cluster's Kibana dashboard can be found at:
- [Monitoring cluster's Kibana](https://b1c5336b505d4c9794a9ebb3f912648e.us-east-1.aws.found.io:9243/app/kibana)


## Kinesis
Quay.io uses Kinesis to stream its action logs into Elasticsearch.


## Logstash
A seperate logstash instance(s) are used to process the action logs from Kinesis to Elasticsearch. Logstash uses a DynamoDB table to keep track of progress across shards in Kinesis:
- [Logstash's DynamoDB table](https://console.aws.amazon.com/dynamodb/home?region=us-east-1#tables:selected=quay-prod-kinesis-logstash-elasticsearch;tab=items)


## Encountered Issues
- [Commonly encountered Elasticsearch issues](../issues/action_logs.md)


## Filing a support ticket to Elastic
When everything else fails, file a ticket to [Elastic](https://support.elastic.co/customers/s/)
