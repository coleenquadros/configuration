# Web RCA production Down

## Severity: Low

## Impact

- Currently there's no impact.

## Summary

This SOP described the required operations to perform in case Web RCA is down.

## Access required

- View access to the stage cluster to confirm PODs health.

## Steps

- Confirm that the PODs health. Check the presence of the service.
- Optionally try to remove the POD and have it re-created from the deployment config. Manually trigger the deployment pipeline.

## Escalations
- Ping the @web-rca handle on Slack # FIXME: create the handle!
