# SOP

## Glitchtip Web/Worker/Beat Down

### Severity: Critical

### Impact

* `glitchtip-web` is down - the web UI is not available.
* `glitchtip-worker` is down - background tasks are not running.
* `glitchtip-beat` is down - no scheduled tasks are running.

### Summary

A glitchtip component is down and not running.

### Access required

View access to clusters and namespaces where pods are running in ([glitchtip in visual-app-interface](https://visual-app-interface.devshift.net/services#/services/glitchtip/app.yml)).

### Steps
- Log into the console and verify if glitchtip pods are up/stuck etc.
- Review the logs of the pods to see if there are any errors.
- Optionally, try to restart the pods or manually trigger the deployment pipeline.

### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
