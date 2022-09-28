# SOP

## Glitchtip Low Availability

### Severity: Medium

### Impact
Users are getting errors on API requests.

### Summary
Glitchtip service API is returning an abnormally high number of 5xx Error requests.

### Access required
- View access to the stage or prod cluster + namespace that pods are running in.
    - Stage: https://visual-app-interface.devshift.net/services#/services/glitchtip/app.yml
    - Production: 

### Steps
- Log into the console and verify if glitchtip pods are up/stuck etc.
- Optionally try to remove the pods and have it re-created from the same deployment config. Manually trigger the deployment pipeline.
- Increase the memory limit and redeploy. The reason for increasing the limits is discussed in the Glitchtip load testing [doc](./load-testing.md)
  

### Escalations
- Ping in `#forum-glitchtip` on Slack
- Ping in `#cssre-team-chat` on Slack
