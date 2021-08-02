CyndiPipelineNotValid
=====================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

A Cyndi pipeline is considered valid if the level of consistency of host records in the application database compared to HBI database is over a given threshold (99%).
If the consistency level is below the given threshold the pipeline is considered invalid.
As a result, the given application may present incorrect information to the customers.


Summary
-------

The host records in the application database became out of sync.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

If a pipeline becames out of sync the Cyndi Operator automatically refreshes the pipeline by re-reading all the records from `platform.inventory.events` topic.
If that does not resolve the inconsistency the operator keeps on retrying until consistency is restored.

- Log into the console / namespace
- Verify that a pipeline refresh has been attempted :code:`oc describe cyndi <pipeline name>`

If pipeline refreshes are being attempted over and over but the consistency level falls short of the threshold this may be an indication that the inventory event interface is out of sync with inventory database.
In that case reach out to `platform-inventory-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/SQ7EM63N0>`_ and request the inventory event interface to be re-populated.

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/cyndi?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
