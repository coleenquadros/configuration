# SOP

## Web RCA Low Availability

### Severity: High 

### Impact
Users are getting errors on API requests.

### Summary
Web RCA service API is returning an abnormally high number of 5xx Error requests.

### Access required
- View access to the stage or prod cluster + namespace that pods are running in.
    - Stage: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/ns/web-rca-stage/pods
    - Production: https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/k8s/ns/web-rca-production/pods

### Steps
- Log into the console and verify if web-rca pods are up/stuck etc.
- Optionally try to remove the pods and have it re-created from the same deployment config. Manually trigger the deployment pipeline.
- Increase the memory limit and redeploy.

### Escalations
- Ping the `@status-board` handle on Slack
