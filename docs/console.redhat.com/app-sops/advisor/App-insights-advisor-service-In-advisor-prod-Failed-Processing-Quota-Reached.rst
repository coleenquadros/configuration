App-insights-advisor-service-In-advisor-prod-Failed-Processing-Quota-Reached
===========================================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

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

**Review Logs**
Links to logs for stage & production are listed on the `Advisor dashboard`_ towards the top right.  Review these logs 
to find errors that are occuring.  In particular, adding 'AND levelname:"ERROR"' to the Kibana query can be helpful

**Review Suspect Requests**
You may utilize the *request_id* from the suspect error log and paste this ID directly into Kibana to trace the 
Payload through the Platform and see which components it may have touched. The Payload Tracker may also be utilized 
for tracing the Payload through the Platform by using the same *request_id* and using the `Payload Tracker page`_

**Follow Up Steps**
-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages of severity ERROR.
-  Check for recent changes to the total memory consumption of the application
-  Changes to the above should reflect service changes. Check the repo for code changes, and notify service owners.
-  Check `Kafka Lag`_ to rule out Kafka issues

Escalations
-----------

-  To reach the Advisor engineering team, ping @Dank, @rbrantle, @fjansen or @theute on CoreOS Slack

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Advisor dashboard: https://grafana.app-sre.devshift.net/d/s9df5udMk/advisor-service?orgId=1&refresh=5s&from=now-7d&to=now
.. _Payload Tracker page: https://payload-tracker-frontend-payload-tracker-prod.apps.crcp01ue1.o9m8.p1.openshiftapps.com/track
.. _Kafka Lag: https://grafana.app-sre.devshift.net/d/KGbSSk6Wz/kafka-lag?orgId=1

