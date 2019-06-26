# Prometheus Failed to send alerts

## Severity: Critical

## Impact

- Alerting pipelines broken, we may miss alerts for critical incidents

## Summary

*This alert is only visible on the UI, and won't be delivered to slack/Pagerduty*

Prometheus is unable to send alerts to alertmanager

Note that this is also covered by deadmanssnitch, where we get a Page in case alertmanager hasn't heard from any of our prometheus. 

Please follow the SOP for prometheus-deadmanssnitch
