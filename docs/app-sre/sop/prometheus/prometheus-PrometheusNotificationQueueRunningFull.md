# Prometheus Notification queue running full

## Severity: High

## Impact

- Prometheus operator will fail to apply any new changes to the configuration

## Summary

This pretty much always means back-pressure from Alertmanager

Most likely this means that the Prometheus in question is sending a lot of alerts

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Check Prometheus queue length: `prometheus_notifications_queue_length`
- Check if the rate of the alerts sent per second has been high recently: `sum(rate(prometheus_notifications_sent_total[10m]))` (adjust the range as required)
- Check which alerts were the first to enter firing state to start troubleshooting
- Count the alerts by alertname `topk(10, count(ALERTS{alertstate="firing"}) by(alertname))` to find alerts with high cardinality

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P

- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
