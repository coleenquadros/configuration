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
- Log into the console.
- Review the logs of
  - the `init-api-users` init-container of the `glitchtip-web` pods. This container is responsible for creating the prometheus API user.
  - `web` container of the `glitchtip-web`  pods. This container is responsible for serving the web UI.
- Optionally, try to restart the pods or manually trigger the deployment pipeline.


### Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
