# Service Tool reports high error rate (5xx)

### Impact

This is an internal tool to run day-to-day chores and does not have any major impact. 

### Summary

This alert is fired when the Quayio Service Tool returns 5xx status code for more than 50% of the total incoming requests.

### Access required

- Console access to the cluster+namespace pods are running in.
- Repo access to Service Tool (https://github.com/quay/quay-service-tool)

### Steps

- Log into the console / namespace and verify if pods are up / stuck / etc
- Check oc logs for error messages
- Notify service owners of above errors

### Escalations

- Ping on `#forum-quay` at [CoreOS](https://app.slack.com/client/T027F3GAJ/C7WH69HCY).
