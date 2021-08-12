PlaybookDispatcherNoConnector
=============================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Downstream applications are not informed of state changes in Playbook Dispatcher.
In addition, the database transaction log storage space is being reclaimed which may result in the database consuming all its available storage.


Summary
-------

The event-interface connector is not running.

Access required
---------------

- Console access to the cluster and namespace where pods are running
- Access to the internal KafkaConnect API via TurnPike

Steps
-----

#. Query KafkaConnect API Determine why the connector is not running (`prod <https://internal.console.redhat.com/api/playbook-dispatcher/connect/connectors/playbook-dispatcher-event-interface/status>`_, `stage <https://internal.cloud.stage.redhat.com/api/playbook-dispatcher/connect/connectors/playbook-dispatcher-event-interface/status>`_)
#. Inspect playbook-dispatcher-connect logs for the root cause
#. Try restarting the connector by issuing a POST request to the KafkaConnect API (`prod <https://internal.console.redhat.com/api/playbook-dispatcher/connect/connectors/playbook-dispatcher-event-interface/restart>`_, `stage <https://internal.cloud.stage.redhat.com/api/playbook-dispatcher/connect/connectors/playbook-dispatcher-event-interface/restart>`_)
#. If the problem does not go away after connector restart, escalate to `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
