App-insights-inventory-In-platform-prod-Mq-Not-Processing
=========================================================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Inventory is an app used to track systems registered using data collectors such as insights-client, satellite, etc.

Summary
-------

This alert fires when inventory does not receive any messages within a period of time.
Underlying issues with core platform services such as Kafka and Entitlements may also trigger this alert.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Check the [grafana dashboard](https://grafana.app-sre.devshift.net/d/EiIhtC0Wa/inventory?orgId=1&refresh=5m) and verify that inventory is receiving messages over kafka by checking the "incoming message rate (ingress)" section.
    -  If the incoming message rate is 0, then there is an issue somewhere up the pipeline before Inventory. This could be an issue with:
        -   [Kafka/platform-mq](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/strimzi/app.yml)
        -   [Entitlements](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/entitlements/app.yml)
-  Check the grafana dashboard and verify that the "ingress consumer lag (ingress)" is not consistently increasing.
    -  If the lag is not decreasing over time, it could be an indication that the kafka deployment is unhealthy.
-  Verify that platform's Kafka deployment is healthy.
    -  If not, fixing the kafka deployment issue should resolve this alert.
-  Log into the console for the host-inventory-prod namespace in the prod cluster and verify that the pods in the insights-inventory MQ deployments are up and running without error:
    -   [host-inventory-mq-p1](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/host-inventory-prod/deployments/host-inventory-mq-p1)
    -   [host-inventory-mq-p1](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/host-inventory-prod/deployments/host-inventory-mq-pmin)
-  Check logs / events for pods in the host-inventory-prod namespace. The terminal command for this is `oc get events -n host-inventory-prod -w`.
    -  If you see quota events, try scaling down the number of pods temporarily.
    -  If this is not possible or not working, reach out to AppSRE to make an immediate increase to the quota in the namespace. For a long-term quota change that takes longer to make, make an MR that modifies the host-inventory-quota.yml file.
-  Check to see if there were any recent deployments.
    -  If there was a Prod deploy recently which may be causing the issue, a deployment rollback should be safe and get things running again until the team can be pinged. To do this, create an MR in app-interface that reverts the most recent MR updating host-inventory's [deployment file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/host-inventory/deploy-clowder.yml).
    -  If you see any AWS-related connectivity issues, see if any password was changed in the configuration recently. If it was caused by config, revert that change; otherwise, reach out to AppSRE to see why the values aren't being set correctly.
-  In the event that a pod is not operating correctly, you can safely delete it, and the replica controller will create a new one.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the app (@crc-host-inventory-team)


.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
