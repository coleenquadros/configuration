# SOP

## Edge Low Availability

### Severity: Medium

### Impact
Users are getting errors on API requests.

### Summary
Edge service API is returning an abnormally high number of 5xx Error requests.

### Access required
- View access to the stage or prod cluster + namespace that pods are running in.
    Reference https://visual-app-interface.devshift.net/services#/services/insights/edge/app.yml

### Steps
- Log into the console and verify if Edge pods are up/stuck etc.
- Optionally try to remove the pods and have it re-created from the same deployment config. Manually trigger the deployment pipeline.

### Escalations
- Ping in `#team-edge` on Slack
