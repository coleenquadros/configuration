App-insights-receptor-controller-gateway-In-receptor-prod-5XX-WebSocket-Quota-Reached.rst
=========================================================================================

Severity: Medium
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Receptor-Controller WebSocket endpoint has been unreachable for significant portions of the past 24 hours.

Summary
-------

This alert fires when the Receptor-Controller WebSocket endpoint has returned a quantity of API responses with statuses
in the 500-599 range at or in excess of 5% of the total number of API responses in the past 24 hours.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to the receptor-controller (https://github.com/RedHatInsights/platform-receptor-controller)

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Verify the pods can access the hosted redis instance
-  Verify that redis is working correctly
-  Verify that the redis configuration parameters are configured correctly
-  Check oc logs for error messages with severity of ERROR
-  Notify service owners if changes have occurred in the above
-  If receptor-gateway is showing major issues, a redeploy of receptor-gateway and redis may be necessary and can be safely done.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
