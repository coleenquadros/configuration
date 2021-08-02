app-uhc-prod-down
==============================================

Impact
------

-  UHC Auth Proxy is a critical service for providing a proxy for incoming OCM archives. UHC outages result in OCM data ingestion failures.

Summary
-------

In the past this has been caused by deployment failures or issues involving OpenShift readiness/liveness probes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console for uhc-auth-proxy-prod namespace in the prod cluster and verify if pods in the uhc-auth-proxy deployment are up / stuck / etc
-  Check logs / events for pods in the uhc-auth-proxy-prod namespace
    -  If quota events are seen, temporarily scaling down pods can get things running again.
    -  If the above is not possible or not working, reaching out to a cluster admin to bump up the quote in the namespace is an alternative.
-  Check if there were any recent changes to the deployed code
    -  In this case a deployment rollback should be safe and get things running again until the team can be pinged.

  Check uhc-auth-proxy health dashboard (https://grafana.app-sre.devshift.net/d/NncCcICiz/uhc-auth-proxy-health?orgId=1&var-datasource=crcp01ue1-prometheus)
  Check platform operational dashboard (https://grafana.app-sre.devshift.net/d/0fmN7EWGz/platform-health?orgId=1&var-datasource=crcp01ue1-prometheus)

Escalations
-----------

-  Escalate to console.redhat.com engineering team per `Incident Response Doc`_

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE

