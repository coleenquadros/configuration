XJoinPipelineRefreshing
=======================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------
The XJoin Operator will restart the xjoin-kafka-connect-strimzi instance if it becomes unavailable.
While Kafka Connect is unavailable, the XJoin pipeline is unable to be refreshed if it becomes out of sync. This could lead to
the HBI data becoming stale. As a result, the HBI application may present incorrect information to the customers.

Summary
-------

Multiple consecutive Kafka Connect restarts occurred.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

It is necessary to determine the cause of frequent restarts.

Inspect the Kafka Connect pod events. There may be a resource issue preventing the pods from fully starting.

Inspect the Kafka Connect deployment's logs. After initial startup, the logs should be fairly quiet aside from periodic polling messages. If the logs are spamming WARN/ERROR level messages
ping `platform-inventory-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/SQ7EM63N0>`_ to investigate.

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/xjoin?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
