# Service Tool Down

### Impact

This is an internal tool to run day-to-day chores and does not have any major impact. 

### Summary

This alert is fired when the Quayio Service Tool is not starting.

### Access required

- Console access to the cluster+namespace pods are running in.
- Repo access to Service Tool (https://github.com/quay/quay-service-tool)

### Steps

- Log into the console / namespace and verify if pods are up / stuck / etc
- Check oc logs for error messages
- Notify service owners of above errors

### Escalations

- Ping on `#forum-quay` at [CoreOS](https://app.slack.com/client/T027F3GAJ/C7WH69HCY).
