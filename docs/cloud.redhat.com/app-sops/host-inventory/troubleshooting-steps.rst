Troubleshooting host-inventory
============================

Summary
-------

-  If host-inventory is not working as expected, use these recommendations for troubleshooting.

Access required
---------------

-  Console access to the cluster & namespace pods are running in. 

Steps
-----

-  Log into the console for the host-inventory-prod namespace in the prod cluster and verify that the pods in the insights-inventory deployment are up / stuck / etc 
-  Check logs / events for pods in the host-inventory-prod namespace.
    -  If quota events are seen, try scaling down the number of pods temporarily.
    -  If this is not possible or not working, reach out to AppSRE to bump up the quota in the namespace.
-  Check to see if there were any recent deployments.
    -  If there was a deploy recently, a deployment rollback should be safe and get things running again until the team can be pinged.
    - To do this, create an MR in app-interface that reverts the change to host-inventory's deploy.yml file.
-  In the event that a pod is not operating correctly, you can safely delete it, and the replica controller will create a new one.

  Check host-inventory's Grafana dashboard (https://grafana.app-sre.devshift.net/d/EiIhtC0Wa/inventory?orgId=1&refresh=5m)

Escalations
-----------

-  Escalate to cloud.redhat.com engineering team per `Incident Response Doc`_

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
