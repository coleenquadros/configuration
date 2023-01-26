ProdRHOSAKPartitionsHigh
====================

Severity: High
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  This alert fires when the current partition count on RHOSAK is at 80% of the defined limit.

Summary
-------

Our RHOSAK message queue puts a hard limit on the number of topic partitions, after which no more topics may be created. This alert fires at 80%+ of that limit.

Access required
---------------

-  Access to the ConsoleDot RHOSAK instances
-  Access to grafana

Steps
-----

-  Check with App Teams to see if any topics can be decommissioned
-  Open a ticket with RHOSAK support
-  Ping Chris Mitchell if available
-  Further escalation is described in https://source.redhat.com/groups/public/sre-services/sre_services_wiki/escalating_kafka_strimzi_amq.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
