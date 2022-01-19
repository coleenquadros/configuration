## Web RCA High Latency

### Severity: Medium

### Impact
Users are experiencing high/slower latency on API requests.

### Summary
Web RCA service API is having an abnormally high number of requests with high latency.

### Access required
- View access to the stage or prod cluster to confirm PODs health.

### Steps
- Confirm that the PODs health. Check the presence of the service.
- Optionally try to remove the POD and have it re-created from the deployment config. Manually trigger the deployment pipeline.

### Escalations
- Ping the `@status-board` handle on Slack
