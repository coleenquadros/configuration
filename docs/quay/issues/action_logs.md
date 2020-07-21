# Debugging action logs issues
API calls can be made through the [web console](https://cloud.elastic.co/deployments/53fb9e7a99a34ba7a37119f3a59dc8b9/elasticsearch/console)
or by making a request using the credentials as a basic auth header.

## Credentials
The credientials for the production cluster are stored in Vault, in `quayio-prod-shared-secrets/tools_misc_secrets` under the `elastic_clusters_and_logins.txt` key.
See [quayio](../quayio.md) on how to access Vault.

## Check the cluster health status
```
GET /_cluster/health
```
#### Yellow cluster status
A yellow cluster indicates that one or more **replica** shard is unassigned. This can happen
when a node leaves the cluster. It should usually fix itself eventually if the node is able to
rejoin the cluster.

#### Red cluster status
A red cluster indicates that one or more **primary** shard cannot be allocated.
This means the index will be missing documents when querying and no new documents can be written to the index during that time.

### Check the nodes status
```
GET /_nodes/stats
```
The production cluster's metrics are sent to a separate monitoring cluster.
These metrics can be viewed in the monitoring cluster's Kibana dashboard:
https://b1c5336b505d4c9794a9ebb3f912648e.us-east-1.aws.found.io:9243/app/monitoring#/elasticsearch?_g=(cluster_uuid:HTov8q8WSP2pM3i6Jb2sEA)

### Diagnosing unassigned shards
To get information about which shards are not able to get assigned:
```
GET _cat/shards
```

To get information about recent shard allocation issues:
```
/_cluster/allocation/explain?pretty
```

The above queries should give a good idea as to why a shard is not being allocated.
Some things to look for as to why a shard is unassigned:
- Check if a node is down and a replica has no available node to be assigned to.
- Check that an index's `number_of_replicas` setting is not set higher than the available number
  of nodes. e.g If two nodes can be allocated a new index, the max `number_of_replicas` should be 1
  (1 primary + 1 replica)
- Check that the number of shards for a node does not exceeds the `total_shards_per_node` settings
- Some allocation rule does not allow a shard to be allocated to some available nodes (e.g only *hot* nodes are assigned shards)

If a shard failed to get allocated, and there are enough eligible nodes for that shard, try to force a retry on the failed shard allocation
(the body must be an empty JSON object):
```
POST /_cluster/reroute?retry_failed=true
{}
```
### Low disk space
Disk space usage has a threshold (85%) where shards (primary and replica) will not be assigned if the disk usage is above that level.
This can cause the cluster's health to be `yellow` if only a replica is not assigned, or `red` if both a primary and replica are not able to be assigned.
Things to look for:
- Make sure there is enough space in the cluster: there may be a need to scale up
- Make sure the indices are being archived correctly: There should only be around ~30 logentry indices at any time

## Restarting the cluster
If the above does not work, try and do a full restart of the cluster from Elastic's web console:
https://cloud.elastic.co/deployments

## Reindexing data from Kinesis
In the case where the data would need to be reindexed, delete the DynamoDB table entries used for
Logstash's checkpoints, in which case Logstash will start at the beginning of each Kinesis shard
again.


## Filing a support ticket to Elastic
When everything else fails, file a ticket to [Elastic](https://support.elastic.co/customers/s/)
