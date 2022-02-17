# Pods continually restarting

## Description

All Clair pods should be long living and any unexpected restart (i.e. a restart is not scheduled by the node for tenancy reasons) should be treated as unexpected.

## Observed

Openshift console pods view.

## Debugging steps:
- Browse to the logs in [Cloudwatch](logs.md)
- Use the query:
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.pod_name = "<POD THAT RESTARTED>"
| sort @timestamp desc
```
- Check for any log messages immediately before the pod restart.
- Check the Last State of the container: 
```
oc describe pod <POD THAT RESTARTED> | grep "Last State" -A 3
```

## Resolution steps:
- If the logs show the application is panicking, contact Quay oncall, panics are always unexpected.
- If kubernetes shows the termination reason to be a resource issue then the resources assigned to the container should be increased (500 Mb of mem is a good step).
