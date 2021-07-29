App-platform-legacy-bridge-In-platform-legacy-bridge-prod-201-Quota-Reached
=============================================================

Severity: medium
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Platform Legacy Bridge has not been able to succesfully bridge an upload from Platform to the Classic API in the last hour.

Summary
-------

This alert fires when the Platform Legacy Bridge cannot bridge an upload from the Platform to the Classic API.
The most likely causes are the following:

-  The RabbitMQ deployment running in the Legacy v3 Cluster hitting an error or ran out of memory. This is the most likely scenario.
-  A Kafka outage or connection issue.
-  The Engine running in the Legacy v3 Cluster could not be properly functioning
-  Possible but unlikely: the Platform Legacy Bridge is receiving malformed messages and cannot process.

Access required
---------------

-  Console access to the cluster+namespace pods are running in for the `Platform Legacy Bridge`_
-  Console access to the cluster+namespace pods are running in for the `Insights API`_, Engine, and `RabbitMQ`_

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  First check that `RabbitMQ`_ is running properly in the v3 cluster. Check for container restarts or alarms in the pod logs. Delete/bounce the suspect pods. Note: The RabbitMQ pods are part of a stateful set. Easiest to find them by going to "Applications" then "Stateful Sets."
-  After bouncing RabbitMQ check the Platform Legacy Bridge Grafana charts to see if traffic starts flowing again. This usually takes a few minutes.
-  If traffic isn't flowing yet then check the `Insights API`_ for an abnormal amount of container restarts or logs of severity ERROR. Bounce the deployment.
-  Check the Platform Legacy Bridge Grafana charts again after a few minutes to see if traffic is flowing.
-  If traffic still isn't flowing check the `Platform Legacy Bridge`_ for an abnormal amount of container restarts or logs of severity ERROR. Bounce the deployment.
-  In all cases check oc logs for error messages with severity of ERROR or abnormal container restarts.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _RabbitMQ: https://console.insights.openshift.com/console/project/insights-prod/browse/stateful-sets/rabbitmq-cluster?tab=details
.. _Insights API: https://console.insights.openshift.com/console/project/insights-prod/browse/dc/insights-api?tab=history
.. _Platform Legacy Bridge: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/platform-legacy-bridge-prod/deployments
