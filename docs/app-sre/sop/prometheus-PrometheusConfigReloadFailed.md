# Prometheus Config Reload Failed

## Severity: High

## Impact

- Prometheus config changes will not be applied

## Summary

This alert fires when prometheus cannot reload its configuration. Usually caused by linting issues or invalid parameters in the configuration files for prometheus

## Access required

- Console access to the cluster+namespace this operator pod is running in
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-prometheus/prometheus/
- https://gitlab.cee.redhat.com/service/app-interface/blob/master/resources/app-sre/app-sre-prometheus/

## Steps

- Check logs for the prometheus pods in the said namespace
- Check if there were any recent changes to the CR's in the namespace
- Once problematic CR is identified, roll back changes or fix the issue

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P

- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
