# App-edge-api-service-In-edge-prod-Error-Rate-Is-High

Severity: Pagerduty

## Incident Response Plan

`Incident Response Doc` (1) for console.redhat.com

## Impact

-  Edge Fleet Management is a Service that provides Management and Automation for RHEL for Edge. This includes provisioning, lifecycle management, custom image creation, upgrade deployment, upgrade validation, canary roll-outs, and inventory management. If there are no pods up in the production environment, customers aren't being able to use the fleet management product at all.

## Summary

Note:  This service is deployed via `Clowder` (2).

This alert fires when the Edge pod(s) drop and/or Prometheus cannot scrape metrics.
Usually caused caused by pods going offline or a Prometheus problem.

## Access required

-  Console access to the cluster+namespace pods are running in.

## Steps

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the Advisor(-environment) namespace
-  Check if there were any recent changes to the CR's in the namespace
-  If this was caused by a deployment, mitigate the incident by doing a rollback to the latest working deployment. If this works, the alert should be resolved and the team must be contacted to fix the new application version.
-  If not, investigate if this could be a infrastructure incident
-  Gather all information and escale the alert properly if needed

## Escalations

-  Ping more team members if available
-  Ping the engineering team that owns the APP

## Related links

- (1) Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE(!)
- (2) Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst
