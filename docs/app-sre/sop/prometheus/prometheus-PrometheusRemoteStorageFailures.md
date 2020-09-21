# PrometheusRemoteStorageFailures

## Severity: High

## Impact

- Metrics from Prometheus fail to write into remote storage

## Summary

Prometheus fails to write metrics into remote storage using the remote write API

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Check the `Prometheus` CR in question's `spec.remotewrite.url` and then validate that the URL is exposed via a route somewhere
- Check the Prometheus pod logs and investigate accordingly
- Check the connectivity between Prometheus pods and remote write endpoint using a debug pod

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
