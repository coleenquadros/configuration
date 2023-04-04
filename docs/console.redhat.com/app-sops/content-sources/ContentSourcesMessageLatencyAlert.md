ContentSourcesLatencyAlert
==========================

Impact
------

Content Sources is not processing incoming events quickly enough.

Summary
-------

This alert fires when a high number of messages are not being processed within a set amount of time.

Access required
---------------
- The stage cluster to view the [content-sources-stage namespace][content-sources-stage-namespace].
- The production cluster to view the [content-sources-prod namespace][content-sources-prod-namespace].
- The stage Kibana instance to view the [content sources stage logs][content-sources-kibana-stage].
- The production Kibana instance to view the [content sources production logs][content-sources-kibana-prod].
- The content sources [grafana dashboard][grafana].

[content-sources-stage-namespace]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/k8s/ns/content-sources-stage/services
[content-sources-prod-namespace]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/project-details/ns/content-sources-prod
[content-sources-kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now%2Fd,to:now%2Fd))&_a=(columns:!(_source),filters:!(),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_group:content'),sort:!())
[content-sources-kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now%2Fd,to:now%2Fd))&_a=(columns:!(_source),filters:!(),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_group:%22content-sources-prod%22'),sort:!())
[grafana]: https://grafana.app-sre.devshift.net/d/content-sources/content-sources

Steps
-----
- View the namespace to verify content-sources pods are running.
- Increase the pod count for workers (currently content-sources-backend-kafka-consumer) to help process more data.

Escalations
-----------

[Escalation policy](data/teams/insights/escalation-policies/crc-content-sources-escalations.yml).
