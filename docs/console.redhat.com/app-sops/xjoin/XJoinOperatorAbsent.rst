XJoinOperatorAbsent
===================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Even without XJoin Operator pod running, the existing XJoin pipelines will continue to work for some time.
However, should state of any of the pipelines change (pipeline becomes invalid, configuration change, state deviation, new pipeline provisioned), these changes will not be reconciled.
Therefore, the operator pod should be brought back as soon as possible.

Summary
-------

XJoin Operator pod is not running.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

- Log into the console / namespace
- Check the pod logs (if applicable) :code:`oc logs --tail=20 xjoin-operator-controller-manager-*`
- Check the pod logs of the previous pod (if applicable) :code:`oc logs --tail=20 -p xjoin-operator-controller-manager-*`
- Check the deployment details for any problem indication :code:`oc describe deployment xjoin-operator-controller-manager`
- Check what version of operator is running and what phase it is in :code:`oc get csv`

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/xjoin?orgId=1&refresh=1m>`_ (Operator row)

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
