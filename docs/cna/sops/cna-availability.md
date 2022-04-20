# SOP

## CNA Low Availability

### Severity: Medium

### Impact
Users are getting errors on API requests.

### Summary
CNA service API is returning an abnormally high number of 5xx Error requests.

### Access required
- View access to the stage or prod cluster + namespace that pods are running in.
  - Stage: #UPDATE 
  - Production: #UPDATE

### Steps
- Log into the console and verify if web-rca pods are up/stuck etc.
- Optionally try to remove the pods and have it re-created from the same deployment config. Manually trigger the deployment pipeline.
- Increase the memory limit and redeploy.

### Escalations
- Ping the `@status-board` handle on Slack
