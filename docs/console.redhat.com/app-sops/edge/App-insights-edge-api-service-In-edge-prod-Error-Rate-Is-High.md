# App-insights-edge-api-service-In-edge-prod-Error-Rate-Is-High

Severity: Pagerduty

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact

- Edge Fleet Management is a Service that provides Management and Automation for RHEL for Edge. This includes provisioning, lifecycle management, custom image creation, upgrade deployment, upgrade validation, canary roll-outs, and inventory management.
- If the error rate is high, we might have an impact on our availability SLO and the customer experience might be degraded.

## Summary

Note:  This service is deployed via [Clowder](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst).

This alert fires when Edge API has been throwing 5xx errors at least 50% of the time for the last 10 minutes which can be a problem for our Availability SLO in the long term.

## Access required

- Console access to the cluster+namespace pods are running in.

## Steps

- Log into the console / namespace and verify if all pods are running and receiving requests.
- Check logs / events for Edge API pods.
- Check if any deployments or changes in the application happened closer to the time the requests started to return errors.
- Check infrastructure metrics on the OpenShift console for edge-api-service (Deployments -> edge-api-service -> Metrics) and take notes.
- Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations

- <https://visual-app-interface.devshift.net/services#/services/insights/edge/app.yml>
