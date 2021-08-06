App-payload-tracker-In-payload-tracker-prod-Downtime-Quota-Reached
==================================================================

Severity: Low
-------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Payload Tracker service has been unreachable for significant portions of the past 24 hours.

Summary
-------

This alert fires when the Payload Tracker pod has downtime at or in excess of 5% of the past 24 hours.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the payload-tracker-prod namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the continers if available

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
