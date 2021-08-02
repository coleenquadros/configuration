App-insights-inventory-In-platform-prod-Absent
==============================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Inventory is an APP used to track systems registered using insights_client.

Summary
-------

This alert fires when the puptoo pod(s) drop and/or prometheus cannot scrape metrics.
Usually caused caused by pods going offline or a prometheus problem.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the host-inventory(-environment) namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the continers if available

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP


.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
