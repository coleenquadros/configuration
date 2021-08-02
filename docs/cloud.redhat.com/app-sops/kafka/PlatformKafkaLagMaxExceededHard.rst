PlatformKafkaLagMaxExceededHard
===============================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  This alert fires when the kafka lag has exceeded an expected amount for a set amount of time

Summary
-------

This alert tracks the consumption rate of messages on a given kafka topic and group, and is triggered
if the lag amount exceeds a certain amount for a certain amount of time

In most cases, these alerts will eventually clear on their own, but there are cases where a pod or an application may
have failed. In these events, action may need to be taken to fix this issue. There is no risk of data loss because of this alert
on its own.

The four topics and aops that are currently tracked for lag are:

-  platform.inventory.host-ingress-p1 / Inventory
-  platform.upload.advsior / Puptoo
-  platform.inventory.host-egress / Insights Engine
-  platform.engine.results / Advisor

Access required
---------------

-  Access to the production `Grafana`_ or `Thanos`_ instance in order to see the current lag
-  Access to the `production Openshift cluster`_ to view the affected projects for any errors
-  Access to the `Kibana instance`_ in order to review logs to see if there are any problems causing the failures

Steps
-----

-  Review `Kafka troubleshooting doc`_ for steps to gather information from Kafka
-  Login to `Grafana`_ and view the `PlatformKafkaLagMaxExceeded dashboard`_ to review the topics
-  Once the lagging topic is identified, login to the corresponding project and see if there are any errors in the project or pods
-  If an app is showing major issues, a redeploy of that app may be necessary and can be safely done.

Escalations
-----------

-  Ping platform-infrastructure-dev or platform-data-dev Slack groups for assistance
-  Ping the engineering team that owns the APP
-  Further escalation is described in https://source.redhat.com/groups/public/sre-services/sre_services_wiki/escalating_kafka_strimzi_amq.

.. _Grafana: https://metrics.1b13.insights.openshiftapps.com/?orgId=1
.. _Thanos: http://thanos-query-mnm.1b13.insights.openshiftapps.com/graph
.. _production Openshift Cluster: https://console.insights.openshift.com/console/catalog
.. _Kibana instance: https://kibana-kibana.1b13.insights.openshiftapps.com/app/kibana
.. _PlatformKafkaLagMaxExceeded dashboard: https://metrics.1b13.insights.openshiftapps.com/d/F1dMmgiMz/platformkafkalagmaxexceededhard?orgId=1&from=now-3h&to=now
.. _Kafka troubleshooting doc: https://platform-docs.cloud.paas.psi.redhat.com/backend/kafka.html#troubleshooting

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
