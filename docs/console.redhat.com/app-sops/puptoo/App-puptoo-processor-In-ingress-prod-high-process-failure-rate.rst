App-insights-puptoo-In-ingress-prod-high-process-failure-rate
=============================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Puptoo is an APP used to process uploads.

Summary
-------

This alert fires when we see a high number of archive extractions fail in the puptoo processor

Access required
---------------

-  Access to the production `Grafana`_ instance in order to see the current error count
-  Access to the `Production Openshift cluster`_ to view the ingress-prod namespace for errors in upload-service
-  Access to the `Kibana instance`_ in order to review logs to see if there are any problems causing the failures

Steps
-----

-  Login to `Grafana`_ and view the `Puptoo dashboard`_ to review the topics
-  Login to the ingress-prod project and see if there are any errors in the project or pods
-  If puptoo is showing major issues, a redeploy may be necessary and can be safely done.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP


.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Grafana: https://grafana.app-sre.devshift.net/?orgId=1
.. _Production Openshift Cluster: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/ingress-prod/deployments
.. _Kibana instance: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana
.. _Puptoo dashboard: https://grafana.app-sre.devshift.net/d/EDPmNcdGk/puptoo?orgId=1
