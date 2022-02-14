Host Inventory RDS Free Space Very Low
=====================

Severity: Critical
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

The host inventory RDS database is going to run out of storage in under 24h. When the database runs out of storage, many portions of console.redhat.com will become unavailable and data will be lost.


Summary
-------

The `predict_linear` Prometheus function determed the HBI database will run out of storage very soon (less than 24h).


Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Access to the consoledot AWS RDS resources

Steps
-----

The primary mitigation step is to increase the allocated storage for the Host Inventory RDS database. Afterwards, the HBI team will investigate the root cause of the abnormal database storage size increase.

The database definition is found here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/host-inventory/namespaces/prod-host-inventory-prod.yml#L73

The database parameters are here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/rds-host-inventory-prod.yml


Escalations
-----------

-  Ping `platform-inventory-dev <https://app.slack.com/client/T026NJJ6Z/CQFKM031T/user_groups/SQ7EM63N0>`_
