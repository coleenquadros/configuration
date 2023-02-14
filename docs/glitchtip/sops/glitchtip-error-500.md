# SOP

## Glitchtip Web/Worker/Beat Down

### Severity: Critical

### Impact

Abnormally high error rates may indicate that the service is down.

### Summary

Abnormally high error rate (http code 500).

### Access required

View access to clusters and namespaces where pods are running in ([glitchtip in visual-app-interface](https://visual-app-interface.devshift.net/services#/services/glitchtip/app.yml)).

### Steps
- Log into the console and verify if glitchtip pods are up/stuck etc.
- Review the logs of the pods to see if there are any errors.
- Optionally, try to restart the pods or manually trigger the deployment pipeline.

### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
