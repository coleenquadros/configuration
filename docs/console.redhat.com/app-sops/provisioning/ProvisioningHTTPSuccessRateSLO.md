ProvisioningHTTPSuccessRate
===========================

Impact
------

Provisioning REST API has been returning high rate of error responses.

Summary
-------

This alert fires when provisioning REST API has been returning high rate of error responses.

Access required
---------------
- The stage cluster to view the [provisioning-stage namespace][provisioning-stage-namespace].
- The production cluster to view the [provisioning-prod namespace][provisioning-prod-namespace].
- The stage Kibana instance to view the [provisioning stage logs][provisioning-kibana-stage].
- The production Kibana instance to view the [provisioning production logs][provisioning-kibana-prod].
- The provisioning [grafana stage dashboard][grafana-stage].
- The provisioning [grafana prod dashboard][grafana-prod].

[provisioning-stage-namespace]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/k8s/ns/provisioning-stage/services
[provisioning-prod-namespace]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/project-details/ns/provisioning-prod
[provisioning-kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now%2Fd,to:now%2Fd))&_a=(columns:!(_source),filters:!(),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_group:provisioning'),sort:!())
[provisioning-kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now%2Fd,to:now%2Fd))&_a=(columns:!(_source),filters:!(),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_group:provisioning'),sort:!())
[grafana-stage]: https://grafana.stage.devshift.net/d/211/provisioning?orgId=1
[grafana-prod]: https://grafana.app-sre.devshift.net/d/211/provisioning?orgId=1

Steps
-----
- View the namespace to verify provisioning pods are running.
- View the dashboard to see the trend of errors.
- View the logs to identify specific errors.
- Check status of Sources service if they are not experiencing an outage.

Escalations
-----------

[Escalation policy](data/teams/insights/escalation-policies/crc-provisioning-escalations.yml).
