# Github Mirror Errors

## Severity: High

## Impact

- Any clients using the Github Mirror service as the Github API endpoint
  will not have their requests served.
- All the qontract-reconcile integrations using the Github API will fail.

## Summary

Github Mirror is a Github API endpoint that implements conditional requests,
aiming to save API calls to about the rate limit.

## Access required

- No authorization required for liveness and metrics endpoints.
- Must be an App-SRE Team member for accessing the `app-sre-prod-01` Openshift
  cluster.

## Steps

- Check the liveness endpoint: https://github-mirror.devshift.net/healthz
- Check the metrics endpoint: https://github-mirror.devshift.net/metrics
- Check that the Pods are running in the `github-mirror-production` Namespace
  on the `app-sre-prod-01` cluster.

## Escalations

- Ping the @app-sre-ic user on Slack.
- Follow incident procedure.
