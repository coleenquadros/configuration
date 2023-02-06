# SOP

## Prometheus Failed To Scrape GlitchTip Web

### Severity: Medium

### Impact

Monitoring is not working.

### Summary

Prometheus is not able to scrape the glitchtip-web service.

### Access required

View access to the stage or prod clusters and namespaces that pods are running in ([glitchtip in visual-app-interface](https://visual-app-interface.devshift.net/services#/services/glitchtip/app.yml)).

### Steps
- Log into the console and verify if glitchtip pods are up/stuck etc.
- Review the logs of the pods to see if there are any errors.
- Optionally, try to restart the pods or manually trigger the deployment pipeline.

TODO: Determine the procedure for this alert.
1. Resolution
2. Log capture
3. Issue tracking

* https://glitchtip.devshift.net/api/0/observability/django/
* TODO prometheus token

### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
