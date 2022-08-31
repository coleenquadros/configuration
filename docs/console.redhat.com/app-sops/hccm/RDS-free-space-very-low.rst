Cost Management RDS Free Space Very Low
=====================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

The cost management RDS database is going to run out of storage in under 24h. When the database runs out of storage, many portions of console.redhat.com will become unavailable and data will be lost.


Summary
-------

The `predict_linear` Prometheus function determined the cost management database will run out of storage very soon (less than 24h).


Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Access to the consoledot AWS RDS resources

Steps
-----

The primary mitigation step is to increase the allocated storage for the Cost Management RDS database. Afterwards, the cost management team will investigate the root cause of the abnormal database storage size increase.

The database definition is found here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/hccm/namespaces/hccm-prod.yml#L151

The database parameters are here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/postgres13-parameter-group-cost-management-prod.yml


Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
