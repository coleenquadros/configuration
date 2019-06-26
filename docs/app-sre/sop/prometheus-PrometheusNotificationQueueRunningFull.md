# Prometheus Config Reload Failed

## Severity: High

## Impact

- Prometheus operator will fail to apply any new changes to the configuration

## Summary

Prometheus Operator is seeing a high error rate on its reconcile function. This may be caused due to an invalid CR or incorrect configuration

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Check logs for the prometheus operator in the said namespace
- Check if there were any recent changes to the CR's in the namespace

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
