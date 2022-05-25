Automation Analytics (tower analytics) Disaster Recovery
=================

Impact
------

-   Red Hat Insights for Red Hat Ansible Automation Platform provides a visual dashboard, health notifications, and organizational statistics across different teams using Ansible. You can view it directly from your cloud.redhat.com portal. Log in and analyze, aggregate and report on data for your Red Hat Ansible Automation Platform deployments, and see how your automation is running in your environment.

Data Loss
---------

-   As this is analytics information, the impact to customer is minimal.  Analytics can tolerate data loss for an arbitrary amount of 'reasonable time', such as 24 hour period to recover the database.  'Best effort' should be approach in determining the recovery strategy, in relation to the time tradeoffs and technical difficulties.
-   Further information about data loss can be found in the [architecture document](https://docs.google.com/document/d/1VBpOkT5LmUOg1zcVurJr-M13V-kD4-XNUBf3zMgYAag/edit#heading=h.yhr7yi6vsbbp)

Summary
-------

-   Follow these steps to recover from disaster.

Steps
-----

-   This is a clowder managed app with upstream dependancies on kafka, postgres, s3 and vault. [app](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/tower-analytics/namespaces/tower-analytics-prod.yml)
-   If secrets have been lost and are causing volume mount errors preventing the pod from scheduling, reach out to the engineering team to reissue them.
-   If the RDS database has been corrupted reach out to engineering to aid with backup recovery.  Alternatively, use [Database restore from snapshot](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#create-rds-database-from-snapshot) to restore the database from a previous snapshot prior to the errors occuring.

Escalations
-----------

-   [Engineering Team](https://gitlab.cee.redhat.com/search?search=%2Fteams%2Finsights%2Froles%2Fautomation-analytics.yml&nav_source=navbar&project_id=13582&group_id=5301&search_code=true&repository_ref=master)
-   [Engineering manager](https://visual-app-interface.devshift.net/services#/services/insights/tower-analytics/app.yml)

