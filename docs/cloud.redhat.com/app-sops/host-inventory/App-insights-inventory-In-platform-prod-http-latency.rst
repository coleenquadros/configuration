App-insights-inventory-In-platform-prod-http-latency
====================================================

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

This alert may fire because of an underlying issue in dependency services, the OSD cluster itself or inventory codebase.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Make sure that there are no issues in 3scale, RBAC and xjoin-search.
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
