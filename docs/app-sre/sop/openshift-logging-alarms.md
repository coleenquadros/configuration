# Openshift Logging Alarms

## ElasticsearchStatusCritical

### Impact

- Elasticsearch server status is Red.

### Summary

A red cluster status means that at least one primary shard and its replicas are not allocated to a node. Some of all cluster data is unavailable.

This currently only affects the internal openshift-logging clusters, so the only thing we can do is to escalate.

### Escalations

- [Create a SREP SNOW ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=200813d513e3f600dce03ff18144b0fd)

## ElasticsearchNoSpaceWithin48h

### Impact

- Elasticsearch server is getting out of space

### Summary

Elasticsearch server is getting out of space and will be unavailable if this continues.

This currently only affects the internal openshift-logging clusters, so the only thing we can do is to escalate.

### Escalations

- [Create a SREP SNOW ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=200813d513e3f600dce03ff18144b0fd)

## ElasticsearchLowAvailableSpace

### Impact

- Elasticsearch server is getting out of space

### Summary

Elasticsearch server is getting out of space and will be unavailable if this continues.

This currently only affects the internal openshift-logging clusters, so the only thing we can do is to escalate.

### Escalations

- [Create a SREP SNOW ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=200813d513e3f600dce03ff18144b0fd)
