App-export-service-In-export-service-prod-throughput
==================================================================

Severity: Pagerduty
-------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Export service is unable to handle the required throughput, affecting user experience.

Summary
-------

This alert fires when the Export Service throughput is below 100 requests per second or 95% of requests < 1000ms in the past 24 hours.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the export-service-prod namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the containers if available

Escalations
-----------

-  Contact the team in the #team-consoledot-pipeline slack channel
-  Ping the engineering team using @crc-pipeline-team

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
