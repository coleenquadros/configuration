PlaybookDispatcherSLOAvailability
=================================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Playbook Dispatcher has been unavailable for a significant portion of past 7 days.


Summary
-------

The ratio of failed requests exceed 5% over last 7 days.

Access required
---------------

- Grafana dashboard
- Kibana

Steps
-----

#. Examine the API logs to identify the root cause of failure (the correct URL is part of the alert)
#. Examine the dashboard to identify the trend of failure(s) (the correct URL is part of the alert)
#. If the failure(s) are caused by a problem with a dependency (database, kafka, RBAC, etc.) escalate to the relevant team. Otherwise, escalate to `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
