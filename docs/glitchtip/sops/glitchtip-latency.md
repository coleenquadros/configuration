# SOP

## Glitchtip High Latency

### Severity: Medium

### Impact
Users are experiencing high/slower latency on API requests.

### Summary
Glitchtip service API is having an abnormally high number of requests with high latency.

### Access required

View access to the stage or prod clusters and namespaces that pods are running in ([glitchtip in visual-app-interface](https://visual-app-interface.devshift.net/services#/services/glitchtip/app.yml)).

### Steps
- Log into the console and verify if glitchtip pods are up/stuck etc.
- Review the logs of the pods to see if there are any errors.
- Optionally, try to restart the pods or manually trigger the deployment pipeline.


### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
