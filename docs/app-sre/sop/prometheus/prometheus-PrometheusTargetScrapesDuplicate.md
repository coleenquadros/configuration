# Prometheus Target scrapes duplicate

## Severity: Medium

## Impact

- Duplicate timeseries in Prometheus

## Summary

Error on ingesting samples with different value but same timestamp

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Find the duplicate timeseries in prometheus pods (0/1):
```
oc logs --tail 10000 -c prometheus prometheus-app-sre-0 | grep Duplicate
```
or
```
oc logs --tail 10000 -c prometheus prometheus-app-sre-0 | grep Duplicate | sed 's/.*series="//;s/{.*//' | sort -u
```
- Remove duplicate entry

## History

This issue has been observed recently with AWS/CloudFront metrics.

Related references:
- https://github.com/prometheus/cloudwatch_exporter/issues/235
- https://github.com/prometheus/cloudwatch_exporter#timestamps

Related app-interface MRs:
- https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/6337
- https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/12374

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
