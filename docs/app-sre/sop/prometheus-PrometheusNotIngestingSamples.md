# Prometheus Not ingesting samples

## Severity: High

## Impact

- Prometheus may not be scraping any data from the desired target list

## Summary

Prometheus is not ingesting any new data from its target. This may mean that the targets have disappeared, target discovery is broken or all the network requests are failing

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Take a look at the /targets page on the Prometheus isntance to understand if there are still targets attempted to be scraped or no targets are being discovered
- If the targets exist and this alert is still firing, check for the possbility of networking issues

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
