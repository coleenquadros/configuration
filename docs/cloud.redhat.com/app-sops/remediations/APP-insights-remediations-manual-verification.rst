App-insights-remediations-manual-verification
========================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Remediations application generates playbooks from snippits obtained through applications on the platform
   (Vulnerabilities, Compliance, Advisor, Patch).

Summary
-------

This SOP describes a manual test for the desired state of Remediations when it's operating correctly.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Registered account on console.redhat.com.
-  Access to the Remediations grafana dashboard.

Steps
-----

-  Log onto console.redhat.com and make your way to the insights bundle.
-  Navigate to any of the applications that report to remediations (vulnerabilites, advisor, compliance, patchman) or the inventory
   service.
-  Find an issue or advisory that you would like to remediate and go through the remediations wizard to create a playbook.
-  Once the playbook has been created, navigate to the Remediations tab and check that the playbook apears there without issue.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
