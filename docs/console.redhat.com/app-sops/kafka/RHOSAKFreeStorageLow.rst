ProdRHOSAKLowFreeStorage
====================

Severity: High
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  This alert fires when the RHOSAK PVCs are at 80%+ of the defined quota.

Summary
-------

Without sufficient free storage, message production to RHOSAK will be delayed or stopped. This alert fires at 80% of the storage limit.

Access required
---------------

-  Access to the ConsoleDot RHOSAK instances
-  Access to grafana

Steps
-----

-  Check ConsoleDot RHOSAK graph in Grafana to determine the cause of data growth
-  Check ConsoleDot apps for high-traffic rates
-  Open a ticket with RHOSAK support
-  Ping Chris Mitchell if available
-  Further escalation is described in https://source.redhat.com/groups/public/sre-services/sre_services_wiki/escalating_kafka_strimzi_amq.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
