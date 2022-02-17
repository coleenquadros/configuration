# PVC Volumes filling to capacity

## Description

When Clair is indexing container layers it downloads them into a PVC and performs various scans on them. After indexing these layers are deleted, however, certain corner-cases can cause the layers to be persisted after the indexing job has finished. If this happens enough times the PVC will fill up. (NOTE: In theory this shouldn't ever happen as the PVC being full will cause the container to restart which runs an init-container to wipe the PVC, but the SOP is included just incase).

## Observed

It is difficult to observe in metrics as AWS doesn't provide a way to observe storage % used over time.

## Debugging steps:
- Browse to the logs in [Cloudwatch](logs.md)
- Use the query:
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter level = "error"
| sort @timestamp desc
```
- Check for log messages saying there is no space left on the device.

## Resolution steps:
- Restart the offending pods, this will cause the init-container to run and wipe the volume. If that does not fix the situation or the volumes continue to be filled; call Quay oncall (link).
