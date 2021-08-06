PlaybookDispatcherValidatorProducerError
========================================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Customer playbook artifact uploads are not processed.


Summary
-------

The validator component fails to produce kafka messages.

Access required
---------------

- Grafana dashboard
- Kibana

Steps
-----

#. Examine the consumer logs to identify the root cause of failure (the correct URL is part of the alert)
#. If the failure is caused by a problem with Kafka, escalate to the relevant team. Otherwise, escalate to `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
