App-insights-receptor-controller-gateway-In-receptor-prod-Response-Delivery-Error-Quota-Reached
===============================================================================================

Severity: Medium
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Successful processing is paramount to service success. This alert indicates gaps in data for a large volume of engine results.

Summary
-------

This alert fires if Receptor-Controller Gateway has failed to successfully send messages to Kafka
at or in excess of 5% of the total number of properly-formatted messages consumed from the connected receptor nodes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to the receptor-controller (https://github.com/RedHatInsights/platform-receptor-controller)

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages of severity ERROR.
-  Check the repo for code changes, and notify service owners.
-  Verify that kafka is working correctly
-  Verify that the kafka configuration parameters are configured correctly

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
