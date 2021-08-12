PlaybookDispatcherAbsent
========================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Playbook Dispatcher may not be available if some of its component(s) are not running.


Summary
-------

Playbook Dispatcher pod(s) are not running.

Access required
---------------

-  Console access to the cluster and namespace where pods are running

Steps
-----

- Log into the console / namespace
- Use `oc describe` to inspect the pod(s), deployment or ClowdApp and determine the root cause

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
