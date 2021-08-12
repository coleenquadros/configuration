ProdMQAllBrokersDown
====================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  This alert fires when all the Kafka brokers are unavailable.

Summary
-------

The message queue is a crucial piece of the insights platform, this alert is fired when all brokers are down.

Access required
---------------

-  Console access to the cluster+namespace this operator pod is running in
-  Access to grafana

Steps
-----

-  Check logs for the Kafka pods in the said namespace
-  Ping Chris Mitchel if available
-  Further escalation is described in https://source.redhat.com/groups/public/sre-services/sre_services_wiki/escalating_kafka_strimzi_amq.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
