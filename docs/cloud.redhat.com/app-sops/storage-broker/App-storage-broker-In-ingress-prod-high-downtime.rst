App-storage-broker-In-ingress-prod-high-downtime
================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  This alert fires when Storage Broker's downtime has exceeded 2%

Summary
-------

Note:  This service is deployed via `Clowder`_.

This alert tracks the uptime of Storage Broker.

If the app is down, it's important to verify that all necessary secrets and environment variables have been provided.

Access required
---------------

-  Access to the production `Grafana`_ instance in order to see the current error count
-  Access to the `Production Openshift cluster`_ to view the ingress-prod namespace for errors in insights-storage-broker
-  Access to the `Kibana instance`_ in order to review logs to see if there are any problems causing the failures

Steps
-----

-  Login to `Grafana`_ and view the `Storage Broker dashboard`_ to review the topics
-  Login to the ingress-prod project and see if there are any errors in the project or pods
-  Verify that the S3 buckets and AWS keys are still accurate
-  If storage-broker is showing major issues, a redeploy may be necessary and can be safely done.

Escalations
-----------

-  Ping platform-data-pipeline-standup or platform-dev Slack groups for assistance
-  Ping the engineering team that owns the APP

.. _Grafana: https://grafana.app-sre.devshift.net/?orgId=1
.. _Production Openshift Cluster: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/ingress-prod/deployments
.. _Kibana instance: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana
.. _Storage Broker dashboard: https://grafana.app-sre.devshift.net/d/hWJAh5dGk/storage-broker?orgId=1
.. _Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/cloud.redhat.com/app-sops/clowder/clowder.rst
