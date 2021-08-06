xjoinAvailabilitySLOBreach
==========================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

If xjoin is not available, the problem will cascade through applications (host-inventory, remediations, ...) causing these to fail when processing certain customer's queries.


Summary
-------

xjoin-search is failing to process requests.

Access required
---------------

- Kibana
- Grafana
- OpenShift cluster (xjoin namespaces)

Steps
-----

#. Review xjoin-search logs (environment-specific link in the alert) to determine what's causing the failures
#. Use `xjoin-search dashboard <https://grafana.app-sre.devshift.net/d/eqi9ATJWz/xjoin-search?orgId=1>`_ and `xjoin-elasticsearch dashboard <https://grafana.app-sre.devshift.net/d/R-meuUJZk/xjoin-elasticsearch?orgId=1&refresh=1m>`_ to assess the state of xjoin-search and ElasticSearch, respectively.
#. Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_ for assistance

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/cyndi?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
