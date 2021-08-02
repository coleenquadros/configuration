App-payload-tracker-In-payload-tracker-prod-Failed-Processing-Quota-Reached
===========================================================================

Severity: Low
-------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Successful processing is paramount to service success. This alert indicates gaps in data for a large volume of payloads.

Summary
-------

This alert fires The Payload Tracker service has failed to successfully process a quantity of Kafka messages
at or in excess of 5% of the total number of properly-formatted messages consumed from the message queue.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to the payload-tracker service (https://github.com/RedHatInsights/payload-tracker)

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check oc logs for error messages originating within the `process_payload_statuses` function within app.py.
-  Check for recent changes to the total memory consumption of the application
-  Changes to the above should reflect service changes. Check the repo for code changes, and notify service owners.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
