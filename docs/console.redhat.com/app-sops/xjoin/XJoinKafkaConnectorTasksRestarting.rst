XJoinPipelineRefreshing
=======================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------
The XJoin Operator will restart the Kafka Connector tasks when they enter a failed state.
While Kafka Connect task failed, the data in ElasticSearch will be stale.
As a result, the HBI application may present incorrect information to the customers.

Summary
-------

Multiple consecutive Kafka Connector task restarts occurred.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

It is necessary to determine the cause of frequent restarts.

Inspect the Kafka Connector object using `oc get KafkaConnector` then `oc describe KafkaConnector/xjoin.inventory.<version>`.
The status for all tasks should be `RUNNING`. If the tasks is `FAILED` or `ERROR`, note the error mesage. It could be due to
the HBI DB being unavailable or ElasticSearch being unavailable. In that case, furthur investigation into why those are unavailable
is necessary.

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/xjoin?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
