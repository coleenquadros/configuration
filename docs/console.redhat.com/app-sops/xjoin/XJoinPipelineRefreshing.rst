XJoinPipelineRefreshing
=======================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

The XJoin Operator will refresh a pipeline if it becomes out of sync, the pipeline state deviates from the desired state, etc.
If the refresh is not successful the operator will keep on refreshing the pipeline until it converges to a valid state.

While the refresh is happening stale host information is available to the HBI application.
As a result, the HBI application may present incorrect information to the customers.


Summary
-------

Multiple consecutive pipeline refreshes occurred.
This may indicate that the pipeline fails to reach valid state.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

It is necessary to determine the cause of frequent refreshes.

Under certain situations this may be expected - for example when a series of configuration changes were made in a short period of time and the operator refreshed the pipeline multiple times to apply each of them.

Otherwise, this alert indicates that the pipeline is repeatedly failing to reach valid state.

- Log into the console / namespace
- Determine the cause of pipeline refreshes :code:`oc describe xjoin <pipeline name>`

If the pipeline is refreshed because the consistency level falls short of the threshold this may be an indication that a piece of the pipeline is out of sync.
In that case reach out to `platform-inventory-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/SQ7EM63N0>`_. 

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/xjoin?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
