StorageBrokerS3CopyErrorsHigh
=============================

Severity: Pagerduty
-------------------

Impact
------

-  This alert fires when the error count for copying payloads in S3 exceeds 50

Summary
-------

This alert tracks the copy process for Storage Broker. The app is designed to move payloads from one bucket to another inside
S3 and will log errors anytime that copy process fails. 

This error could indicate a loss of connectivity to S3. It's important to check that accurate bucket names are being used in the
env variables, and that the AWS keys have not become outdated.

Access required
---------------

-  Access to the production `Grafana`_ or `Thanos`_ instance in order to see the current error count
-  Access to the `production Openshift cluster`_ to view the ingress-prod namespace for errors in upload-service
-  Access to the `Kibana instance`_ in order to review logs to see if there are any problems causing the failures

Steps
-----

-  Login to `Grafana`_ and view the `Storage Broker dashboard`_ to review the topics
-  Login to the ingress-prod project and see if there are any errors in the project or pods
-  Verify that the S3 buckets and AWS keys are still accurate
-  If storage-broker is showing major issues, a redeploy may be necessary and can be safely done.

Escalations
-----------

-  Ping platform-infrastructure-dev or platform-data-dev Slack groups for assistance
-  Ping the engineering team that owns the APP

.. _Grafana: https://metrics.1b13.insights.openshiftapps.com/?orgId=1
.. _Thanos: http://thanos-query-mnm.1b13.insights.openshiftapps.com/graph
.. _production Openshift Cluster: https://console.insights.openshift.com/console/catalog
.. _Kibana instance: https://kibana-kibana.1b13.insights.openshiftapps.com/app/kibana
.. _Storage Broker dashboard: https://metrics.1b13.insights.openshiftapps.com/d/Z0JGkV6Zz/storage-broker?orgId=1
