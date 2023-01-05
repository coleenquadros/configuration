# Web RCA production Down

## Severity: High 

## Impact

- The WebRCA UI would be down at https://web-rca.devshift.net/.

## Summary

This SOP described the required operations to perform in case Web RCA is down.

## Access required

- View access to the prod cluster to confirm PODs health.

## Steps

- Confirm that the PODs health. Check the presence of the service.
- Optionally try to remove the POD and have it re-created from the deployment config. Manually trigger the deployment pipeline.

## Escalations
- Ping the @status-board handle on Slack
