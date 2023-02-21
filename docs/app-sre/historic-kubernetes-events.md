# Historic Kubernetes Events

Kubernetes events are not stored for long, (3hours per default). However sometimes it might be interesting to see events further in the past. I.e. if you want to debug a failing Job running over night. 

## Storing events

Events are scraped by the event-router component following [this guide](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.12/html/logging/cluster-logging-eventrouter)

The deployment is adapated, so we deploy it into the namespace `app-sre-event-router`. Cause of this, you can access the logs in `app-sre-log` Cloudwatch.

Access via :

* [AWS console](https://744086762512.signin.aws.amazon.com/console)
* [Grafana](https://grafana.app-sre.devshift.net/)

The events will always be stored in the `$cluster.app-sre-event-router` log group.

## Sample queries

Log group used for all: `appsrep05ue1.app-sre-event-router`

### Events per namepsace

```
filter kubernetes.event.metadata.namespace = "app-interface-production"
| sort @timestamp desc
| fields message
```

### Aggregation of event reason per namepsace

filter kubernetes.event.metadata.namespace = "app-interface-production"
| stats count() by kubernetes.event.reason
| sort @timestamp desc 

### Failed scheduling in a namespace

filter kubernetes.event.metadata.namespace = "app-interface-production"
|filter kubernetes.event.reason = "FailedScheduling"
| sort @timestamp desc
| fields message
