# SOP

## Web RCA Low Availability

### Severity: Medium

### Impact
Users are getting errors on API requests.

### Summary
Web RCA service API is returning an abnormally high number of 5xx Error requests.

### Access required

- View access to the stage or prod cluster to confirm PODs health.

### Steps
- Confirm that the PODs health. Check the presence of the service.
- Optionally try to remove the POD and have it re-created from the deployment config. Manually trigger the deployment pipeline.

### Escalations
- Ping the `@status-board` handle on Slack
