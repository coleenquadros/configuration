PlaybookDispatcherConsumerLagIncreasing
=======================================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Customers will see playbook run updates with significant delay.


Summary
-------

Customer playbook artifact uploads are processed slowly or are not processed at all.

Access required
---------------

- Console access to the cluster and namespace where pods are running
- Grafana dashboard
- Kibana
- AWS Console access

Steps
-----

#. Log into the console / namespace
#. Use `oc describe` to inspect the pod(s), deployment or ClowdApp and determine the health of the consumer
#. Examine the consumer logs to identify (the correct URL is part of the alert)
#. Examine the dashboard to identify the trend of upload processing rate (the correct URL is part of the alert)
#. Examine the AWS console to assess the health of the database
#. If the failure or slowdown is caused by a problem with a dependency (database, kafka, RBAC, etc.) escalate to the relevant team. Otherwise, escalate to `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
