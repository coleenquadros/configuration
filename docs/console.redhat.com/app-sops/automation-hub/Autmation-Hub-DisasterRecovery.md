Automation Hub Disaster Recovery
=================

Impact
------

-   Automation Hub provides a portal to search for and access Ansible Content Collections supported by Red Hat and Ansible Partners via the Certified Partner Program.

Summary
-------

Follow these steps to recover from disaster.

Steps
-----

-   If secrets have been lost, reach out to the engineering team to reissue them.
-   If the RDS database has been lost, restore the database from a snapshot following [app-interface instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#create-rds-database-from-snapshot).
-   Otherwise, no Automation Hub specific steps need to be taken, everything is fully configured in app-interface.

Escalations
-----------

See
[https://visual-app-interface.devshift.net/services#/services/insights/automation-hub/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/automation-hub/app.yml)
