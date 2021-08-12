App-insights-advisor-service-In-advisor-prod-Absent
===================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Advisor is an APP used to scan uploads and check them against rules used to check for certain conditions in the uploads.

Summary
-------

Note:  This service is deployed via `Clowder`_.

This alert fires when the Advisor pod(s) drop and/or prometheus cannot scrape metrics.
Usually caused caused by pods going offline or a prometheus problem.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the Advisor(-environment) namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the containers if available
-  Check `Kafka Lag`_ to rule out Kafka issues

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP


.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst
.. _Kafka Lag: https://grafana.app-sre.devshift.net/d/KGbSSk6Wz/kafka-lag?orgId=1

