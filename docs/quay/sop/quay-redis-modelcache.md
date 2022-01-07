# Quay Redis Modelcache

The redis modelcache is used to cache responses from the DB thereby reducing
the load on the DB. In production the modelcache is a clustered Elasticache
instance in `us-east-1` [quayio-production-modelcache](https://console.aws.amazon.com/elasticache/home?region=us-east-1#redis-shards:redis-id=quayio-production-modelcache). You can check out the hit ratio of the modelcache in the [grafana dashboard](https://grafana.app-sre.devshift.net/d/_BkydJaWz/quay-runtime?orgId=1&refresh=1m&from=1640278546922&to=1640282146922&viewPanel=25)


## Disabling redis modelcache

In case of an outage or problem with Elasticache. Modelcache needs to be
disabled.  This can be done by changing the setting `enable_redis_modelcache`
to `false` in the secret template `quay-config-secret` in
`data/services/quayio/namespaces/quayp05ue1.yml`. When redis modelcache is
disabled, you need to restart the pods. Now instead of using the redis cache,
the pods will use memcache which is running inside the pod.

NOTE: Redis modecache is only available in the primary region `us-east-1` and
not available in the backup region `us-east-2`
