entitlements Troubleshooting
============================

Summary
-------

-  If the entitlements service is not running as expected, use these recommendations for troubleshooting

Access required
---------------

-  Console access to the cluster+namespace pods are running in. 

Steps
-----

-  Log into the console for entitlements-prod namespace in the prod cluster and verify if pods in the entitlements deployment are up / stuck / etc 
-  Check logs / events for pods in the entitlements-prod namespace
    -  If quota events are seen, temporarily scaling down pods can get things running again.
    -  If the above is not possible or not working, reaching out to a cluster admin to bump up the quote in the namespace is an alternative.
-  Check if there were any recent changes to the deployed code
    -  In this case a deployment rollback should be safe and get things running again until the team can be pinged.
    -  There is no Redis or RDS component to the entitlements so there is no concern with migrations during deployment rollback
-  In the event that a pod is not operating correctly, there is no concern with bouncing it as needed.

  Check operational dashboard (https://grafana.app-sre.devshift.net/d/0fmN7EWGz/platform-health?orgId=1&var-datasource=crcp01ue1-prometheus)

Escalations
-----------

-  Escalate to console.redhat.com engineering team per `Incident Response Doc`_

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
