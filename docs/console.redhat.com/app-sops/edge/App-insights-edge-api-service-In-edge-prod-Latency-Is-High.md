# App-insights-edge-api-service-In-edge-prod-Latency-Is-High

Severity: Pagerduty

## Incident Response Plan

`Incident Response Doc` (1) for console.redhat.com

## Impact

- Edge Fleet Management is a Service that provides Management and Automation for RHEL for Edge. This includes provisioning, lifecycle management, custom image creation, upgrade deployment, upgrade validation, canary roll-outs, and inventory management. 
- If the error rate is high, we might have an impact on our latency SLO and the customer experience might be degraded.

## Summary

Note:  This service is deployed via `Clowder` (2).

This alert fires when #TODO

## Access required

-  Console access to the cluster+namespace pods are running in.

## Steps

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the Advisor(-environment) namespace
-  Check if there were any recent changes to the CR's in the namespace
-  Check infrastructure metrics (CPU, memory)
-  Investigate app logs on Kibana to get to the offensor endpoint, if any
-  ``oc rsh`` into one of the containers if available and investigate further
-  Contact the engineering team that owns the APP

## Escalations

-  Ping more team members if available
-  Ping the engineering team that owns the APP

## Related links

- (1) Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE(!)
- (2) Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst
