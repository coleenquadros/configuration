# Prometheus Failed to send alerts

## Severity: High

## Impact

- Alerting pipelines broken, we may miss alerts for critical incidents

## Summary

> This alert is only visible on the UI, and won't be delivered to slack/Pagerduty

Prometheus is unable to send alerts to alertmanager

This alert means Prometheus has at least one Alertmanager instance discovered and at least for one of those alerts are failing to be sent.

Note that this is also covered by Deadmanssnitch, where we get a Page in case alertmanager hasn't heard from any of our Prometheus instances 

Please follow the SOP for prometheus-deadmanssnitch
