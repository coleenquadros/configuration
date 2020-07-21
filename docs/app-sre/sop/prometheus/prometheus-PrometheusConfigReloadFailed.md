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
- For changes related to alerting or recording rules: 
  - `oc rsh` into one of the prometheus containers
  - Run `promtool check rules /etc/prometheus/rules/prometheus-app-sre-rulefiles-0/*`
  - This should give you an error message for the rule file which is causing the config reload to fail
- Similarly for potential problems due to the prometheus configuration itself:
  - `oc rsh` into one of the prometheus containers
  - Run `promtool check config /etc/prometheus/config_out/prometheus.env.yaml`
  - This should give you an error message for the rule file which is causing the config reload to fail
- Once problematic CR is identified, roll back changes or fix the issue

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P

- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
