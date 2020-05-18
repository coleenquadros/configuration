# Prometheus TSDB reloads failing

## Severity: High

## Impact

- Unknown

## Summary

Prometheus TSDB reloads failing, typically this is because of some sort of malformed config

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Check Prometheus' logs, they should say the reason why reloads failed
- Check the config for prometheus to see if it is malformed:
`kubectl -n <namespace> get secret prometheus-<name-of-prometheus> -ojson | jq -r '.data["prometheus.yaml"]' | base64 -d | vim -`


## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
