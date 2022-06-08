AutomationAnalyticsRDMSStorageUsage
===================================

Severity: Medium
----------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- If the database fills, the application will cease to process incoming data and other possible side effects

Summary
-------

- This alert fires when the database usage is larger than 0.95 of the quota.  At the time of writing this, this would equate to 14.25TB of 15TB

Steps
-----
- Create PR to increase the database quota
  - https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/rds-tower-analytics-prod.yml#L19

Escalations
-----------

- Ping the `@app-sre-ic` team in the `CoreOS Slack sd-app-sre`_
- Ping the engineering team that owns the APP (`CoreOS Slack Forum-consoledot`_)
- - call `@aa-api-team`

.. _CoreOS Slack sd-app-sre: https://app.slack.com/client/T027F3GAJ/CCRND57FW
.. _CoreOS Slack Forum-consoledot: https://app.slack.com/client/T027F3GAJ/C022YV4E0NA
