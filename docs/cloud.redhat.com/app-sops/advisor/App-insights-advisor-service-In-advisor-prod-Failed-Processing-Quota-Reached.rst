App-insights-advisor-service-In-advisor-prod-Failed-Processing-Quota-Reached
===========================================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for cloud.redhat.com

Impact
------

-  Successful processing is paramount to service success. This alert indicates gaps in data for a large volume of engine results.

Summary
-------

This alert fires if Insights Advisor Service has failed to successfully process a quantity of Kafka messages from the engine
at or in excess of 5% of the total number of properly-formatted messages consumed from the message queue.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to the insights-advisor-service (https://github.com/RedHatInsights/insights-advisor-service)

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages of severity ERROR.
-  Check for recent changes to the total memory consumption of the application
-  Changes to the above should reflect service changes. Check the repo for code changes, and notify service owners.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
