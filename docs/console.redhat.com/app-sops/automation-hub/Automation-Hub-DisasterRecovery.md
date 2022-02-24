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

-   If secrets have been lost and are causing volume mount errors preventing the pod from scheduling, reach out to the engineering team to reissue them.
-   If the RDS database has been corrupted and resulting the following errors, Follow [app-interface instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#create-rds-database-from-snapshot) to restore the database from a previous snapshot prior to the errors occuring.
    ```
    psycopg2.errors.UndefinedTable: relation "XXXXX" does not exist
    ```
    ```
    django.db.utils.ProgrammingError: relation "XXXXX" does not exist
    ```

Escalations
-----------

See
[https://visual-app-interface.devshift.net/services#/services/insights/automation-hub/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/automation-hub/app.yml)
