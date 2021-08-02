XJoinPipelineRefreshing
=======================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------
The XJoin operator was unable to remove a stale resource. This could be a Kafka Connector, Replication Slot, Kafka Topic, ElasticSearch
Pipeline/Index. A stale replication slot will cause the HBI database storage to grow indefinitely. A stale Kafka Topic will use up Kafka
storage space.

Summary
-------

At least one stale resource was found for an hour.

Access required
---------------

- [Troubleshooting] Console access to the cluster+namespace pods are running in.
- [Cleanup] Access to run SQL queries against HBI
- [Cleanup] Access to run REST API calls to Kafka Connect
- [Cleanup] Access to run REST API calls to ElasticSearch
- [Cleanup] Access to delete Kafka Topics in platform-mq namespace

Steps
-----

It is necessary to determine what resources are stale.

View the XJoin operator logs to determine which resource is unable to be deleted and manually delete the resource.

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/xjoin?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
