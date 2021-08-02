CyndiErrorDLQ
=============

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Cyndi kafka consumer failed to process event(s) from HBI event interface.
This indicates software problem in either HBI or Cyndi and will result in data inconsistency until fixed.

Summary
-------

Cyndi kafka consumers failed to process event(s) from HBI.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

- Log into the console / namespace
- Inspect the logs of kafka-connect pods to determine the cause of the problem :code:`oc logs xjoin-kafka-connect-strimzi-connect-*`

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
