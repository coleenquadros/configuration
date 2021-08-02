xjoinLatencySLOBreach
=====================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Excessive latency cascades to user interfaces making certain console.redhat.com applications (host-inventory, remediations, ...) hard to use.
A very high latency may cause certain requests to time out causing a partial outage.

Summary
-------

The latency of requests served by xjoin-search is higher than expected.

Access required
---------------

- Grafana
- OpenShift cluster (xjoin namespaces)

Steps
-----

Use the `Grafana dashboard <https://grafana.app-sre.devshift.net/d/eqi9ATJWz/xjoin-search?orgId=1>`_ determine the source of latency.
Compare the `Total latency panel <https://grafana.app-sre.devshift.net/d/eqi9ATJWz/xjoin-search?viewPanel=13&orgId=1>`_ with `Elasticsearch Latency <https://grafana.app-sre.devshift.net/d/eqi9ATJWz/xjoin-search?viewPanel=23&orgId=1>`_.
This should indicate whether it's ElasticSearch or the subsequent data processing causing the latency.

If the problem is caused by ElasticSearch, verify the state of the ES cluster in AWS console.
If the latency is added outside of ElasticSearch, ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_ for further investigation.

Tools
-----

- `Grafana dashboards <https://grafana.app-sre.devshift.net/d/eqi9ATJWz/xjoin-search?orgId=1>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
