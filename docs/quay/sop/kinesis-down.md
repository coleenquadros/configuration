# Kinesis Down

## Severity: High

## Impact

- Currently the assumed impact (following https://issues.redhat.com/browse/APPSRE-2752) is that a Kinesis outage resolves in a high DB connections count.  This means that Quay will eventually have an outage.

## Summary

This SOP described the required operations to perform in case AWS Kinesis is down.

## Access required

- None

## Steps

- Submit a MR to update the `quay-config-secret` resource in the active Quay cluster. Change the value of `log_provider` from `kinesis_stream` to `elasticsearch`.
    * This value is currently here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/08623b6b494d87258bca778eec86d904284ee1c4/data/services/quayio/namespaces/quayp05ue1.yml#L52
    * The Secret will be applied and Quay pods will be automatically recycled due to: https://gitlab.cee.redhat.com/service/app-interface/-/blob/08623b6b494d87258bca778eec86d904284ee1c4/data/services/quayio/namespaces/quayp05ue1.yml#L46


## Notes

Active Quay cluster is currently `quayp05ue1`.

## Escalations

- Ping the @quay-team handle on Slack
- Create PagerDuty incident (if one doesn't exist) and add the `Quay` Escalation Policy as responders
