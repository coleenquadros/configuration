# Prometheus Operator Node Lookup Errors

## Severity: Critical

## Impact

- Depending on the instance, we will lose application metrics for production systems
- Grafana dashboards using the instance may stop working, explore view will cease to function
- Alerting will be down for all alerts managed by that Prometheus instance 

## Summary

Prometheus SnitchHeartBeat is an always-firing alert. It's used as an end-to-end test of Prometheus through the Alertmanager.

## Access required

- Must be in Github app-sre team `app-sre-observability` to login to application prometheus instances.

## Steps

- Make sure the SnitchHeartBeat alert is not silenced.
- Check the Prometheus and Alertmanager logs to make sure they are communicating properly with https://deadmanssnitch.com/.
- Check that the Pods/VM running the concerned Prometheus instance is available

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P

- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
