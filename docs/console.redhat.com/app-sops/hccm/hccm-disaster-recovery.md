Disaster Recovery
=================

Impact
------

Cost Management processes customer cloud spend and OpenShift uaage data in order to present a visualization of Cloud costs and the cost of running OpenShift along with various breakdowns of the data. If Cost Management is broken, customers will not have an accurage view of their cost for running OpenShift.

Data Loss
---------

Since Cost Management captures data scoped by time (hourly, daily) an outage that effects multiple days will have some effect on OpenShift usage calculation as data will be missing. If the service can be restored within the day along with the restored database snapshot and the queue of uploaded cluster metrics can be processed the customer data will be complete. Otherswise there would be a gap of data which could lead to showing a reduced utilization over the impacted time period.


Summary
-------

Follow these steps to recover from disaster.

Steps
-----

-   This is a clowder managed app with upstream dependancies on kafka, postgres, S3 and vault. [app](https://visual-app-interface.devshift.net/namespaces#/services/insights/hccm/namespaces/hccm-prod.yml)

-   If secrets have been lost and are causing volume mount errors preventing the pod from scheduling, reach out to the engineering team to reissue them.
-   If the RDS database has been corrupted and resulting the following errors, Follow [app-interface instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#create-rds-database-from-snapshot) to restore the database from a previous snapshot prior to the errors occuring.


Escalations
-----------

See
[https://visual-app-interface.devshift.net/services#/services/insights/hccm/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/hccm/app.yml)

