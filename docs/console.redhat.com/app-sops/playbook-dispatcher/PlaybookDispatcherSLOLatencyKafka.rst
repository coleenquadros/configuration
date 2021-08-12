PlaybookDispatcherSLOLatencyKafka
=================================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Latency of processing kafka message has been significantly high over past 7 days.


Summary
-------

The 95th percentile of pending messages exceeds 10,000.

Access required
---------------

- Grafana dashboard
- Kibana

Steps
-----

#. Examine the consumer/validator logs to identify the cause of slow processing (the correct URL is part of the alert)
#. Examine the dashboard to identify the trend performance trend (the correct URL is part of the alert)
#. If the problem is caused a dependency (database, kafka, RBAC, etc.) escalate to the relevant team. Otherwise, escalate to `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
