App-payload-tracker-In-payload-tracker-prod-5XX-Quota-Reached
=============================================================

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

This alert fires when the Payload Tracker API has returned a quantity of API responses with statuses
in the 500-599 range at or in excess of 5% of the total number of API responses in the past 24 hours.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to the payload-tracker service (https://github.com/RedHatInsights/payload-tracker)

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages from one (or multiple) files in the /api directory.
-  Check recent PR for changes made to the API spec, controller definitions, of configuration of the aiohttp server.
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
