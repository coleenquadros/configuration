CyndiNoRunningConnectors
========================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Cyndi relies on Kafka Connectors to keep syndicated data up to date.
If no connectors are running the data is becoming stale.
As a result, the given application may present incorrect information to the customers.


Summary
-------

Pipeline Connectors are not running.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

- Log into the console / namespace
- Check the pipeline events for any indication of a problem :code:`oc describe cyndi <pipeline name>`
- Find the corresponding connector for the affected application :code:`oc get kafkaconnector`
- Inspect the given connector for the cause of failure :code:`oc describe kafkaconnector <connector name>`

Note that Cyndi operator will try to re-create a failed connector automatically.
Once the cause of the connector failure is removed the pipeline will be refreshed and should become valid again.

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/cyndi?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
