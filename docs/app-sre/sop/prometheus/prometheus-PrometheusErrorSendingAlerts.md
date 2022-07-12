# Prometheus Failed to send alerts

## Severity: High

## Impact

- Alerting pipelines broken, we may miss alerts for critical incidents.

## Summary

Prometheus is unable to send alerts to Alertmanager.

This alert means Prometheus has at least one Alertmanager instance discovered and at least for one of those, alerts are failing to be sent.

## Access required

- Must be in Github app-sre team `app-sre-observability` to login to application prometheus instances.

## Steps

- Check that the Pods/VM running the concerned Prometheus instance is available.
- Check recent changes to observability saas deployment jobs.
- Check the Prometheus pods to make sure it can connect properly to all AlertManager pods.
- In case one of the Alertmanager pods is misbehaving, you may see connection problems in the Prometheus logs, e.g.
  ```
  level=error ts=2022-07-10T18:04:29.280Z caller=notifier.go:527 component=notifier alertmanager=http://10.128.4.14:9093/api/v2/alerts count=1 msg="Error sending alert" err="Post \"http://10.128.4.14:9093/api/v2/alerts\": dial tcp 10.128.4.14:9093: connect: no route to host"
  ```
  - You can try restarting it. The worst case scenario is that it doesn't come back, fails to terminate, etc...  After doing it you may check if Alertmanager headless service has the rest of the Alertmanager pods:
  ```
  oc project app-sre
  oc rsh diag-container-XXXXX
  nslookup alertmanager-operated.openshift-customer-monitoring
  ```
  - If you see just two IPs, then Prometheus won't use the bad Alertmanager pod, the alert should autoresolve in a bit and you can concentrate in recovering the failing pod.

## Escalations

- Ping more team members in #sd-app-sre-teamchat
