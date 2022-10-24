Disaster Recovery
=================

Impact
------

Subscription Watch processes customer inventory to track their subscription utilization vs. capacity across multiple Red Hat Products. If Subscription Watch is broken, customers will not have accurate data reported via Subscription Watch to understand their subscription usage versus capacity.

Data Loss
---------

Since Subscription watch captures data scoped by time (daily, weekly, monthly, etc) an outage that effects multiple days will have some effect on customer usage calculation. If the service can be restored within the day along with the restored database snapshot and the job that processes the customer's inventory data is able to complete there will be no loss of data. Otherswise there would be a gap of data which could lead to showing a reduced utilization over the impacted time period. Additionally, since Subscription Watch interacts with various Marketplaces to report product metered data it is also possible that a customer usage could be reported lower than actual usage if the metered telemetry can no longer be sent to the Marketplace vendor.


Summary
-------

Follow these steps to recover from disaster.

Steps
-----

-   This is a clowder managed app with upstream dependancies on kafka, postgres, host-based inventory and vault. [app](https://visual-app-interface.devshift.net/namespaces#/services/insights/rhsm/namespaces/rhsm-prod.yml)

-   If secrets have been lost and are causing volume mount errors preventing the pod from scheduling, reach out to the engineering team to reissue them.
-   If the RDS database has been corrupted and resulting the following errors, Follow [app-interface instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#create-rds-database-from-snapshot) to restore the database from a previous snapshot prior to the errors occuring.


Escalations
-----------

See
[https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml)

