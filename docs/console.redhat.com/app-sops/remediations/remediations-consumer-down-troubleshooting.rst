Remediations-consumer-troubleshooting
===========================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Remediations is an APP that generates Ansible playbooks that remediate issues discovered by Red Hat Insights.

Summary
-------

-  If the remediations-consumer service is not running as expected, use these recommendations for troubleshooting

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----
-  Check operational Dashboard (https://grafana.app-sre.devshift.net/d/KDvc-DmWk/remediations?orgId=1)

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the remediations(-environment) namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the continers if available

- Bounce the consumer pods (This will generally fix most issues with the remediations consumer)

Escalations
-----------

-  Ping more team members if available
-  Ping the platform-data-pipeline SLACK group for assistance


.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
