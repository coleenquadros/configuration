# Prometheus not connected to Alertmanager

## Severity: Critical

## Impact

- Alerting pipelines broken, we may miss alerts for critical incidents

## Summary

> This alert is only visible on the UI, and won't be delivered to slack/Pagerduty

This alert will fire in either of the following cases:

- The discovery for Alertmanager in Prometheus is broken
- The Alertmanager cluster doesn't exist anymore

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Check logs for the prometheus pods in the said namespace/ prometheus service logs on VM's
- Check that alertmanager is up and running on the expected route (alertmanager.<clustername>.devshift.net)
- In the prometheus configuration, check if the credentials to talk to alertmanager are correct
- Investigate the possibility of a network partition if the prometheus is not on the same cluster as alertmanager

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P

- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
