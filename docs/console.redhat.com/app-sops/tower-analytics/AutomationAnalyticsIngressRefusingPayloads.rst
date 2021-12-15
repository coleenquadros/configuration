AutomationAnalyticsIngressRefusingPayloads
====================================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- Customer data sent from Ansible Towers/Platform through Ingress service won't be processed.

Summary
-------

- This alert fires when Ingress service is refusing payloads from Ansible Tower/Platform.

Access required
---------------

Steps
-----

- This issue is related to Ingress service, indirectly to Automation Analytics
- Cannot be solved by Automation Analytics
- Check the Alert's link button in Slack (targeting Kibana logs) for errors

Escalations
-----------

- Ask for assistance in `CoreOS Slack Forum-consoledot`_

.. _CoreOS Slack Forum-consoledot: https://app.slack.com/client/T027F3GAJ/C022YV4E0NA
.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
