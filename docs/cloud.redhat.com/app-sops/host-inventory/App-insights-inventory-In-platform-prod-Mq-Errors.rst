App-insights-inventory-In-platform-prod-Mq-Errors
=================================================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Inventory is an APP used to track systems registered using insights_client.

Summary
-------

This alert usually fires when inventory receives too much bad data from the inventory reporters such as puptoo, yupana etc. and usually resolves itself.
Underlying issues with inventory's codebase may also trigger this alert.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Check the grafana dashboard for any unusually high/low number of messages received by the MQ service.
    -  If so, it may be an indication that bad data triggered the alert and it might resolve itself after some time.
    -  If the alert does not get resolved after a while, follow the steps below.
-  Log into the console for the host-inventory-prod namespace in the prod cluster and verify that the pods in the insights-inventory deployment are up and running without error.
-  Check logs / events for pods in the host-inventory-prod namespace. The terminal command for this is `oc get events -n host-inventory-prod -w`.
    -  If you see quota events, try scaling down the number of pods temporarily.
    -  If this is not possible or not working, reach out to AppSRE to make an immediate increase to the quota in the namespace. For a long-term quota change that takes longer to make, make an MR that modifies the host-inventory-quota.yml file.
-  Check to see if there were any recent deployments.
    -  If there was a deploy recently, a deployment rollback should be safe and get things running again until the team can be pinged. To do this, create an MR in app-interface that reverts the change to host-inventory's deploy.yml file.
    -  If you see any AWS-related connectivity issues, see if any password was changed in the configuration recently. If it was caused by config, revert that change; otherwise, reach out to AppSRE to see why the values aren't being set correctly.
-  In the event that a pod is not operating correctly, you can safely delete it, and the replica controller will create a new one.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP


.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
