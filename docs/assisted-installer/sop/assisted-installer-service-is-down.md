# Assisted Installer Service Is Down Errors

## Severity: Critical

## Impact
- Users are unable to access Assisted Installer service

## Summary
There are 0 pods serving Assisted-installer service.

## Access required

- Access to the cluster that runs the assisted-service Pod
- View access to the namespaces:
  - assisted-installer

## Steps
- Check the production endpoint:

    `curl https://api.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"`

  If service is up you should get a list of clusters, might be `[]` if you never created any clusters.

- Check that the Pods are running in the `assisted-installer` Namespace on the `app-sre-prod-04` cluster.

- Check what is the reason the pods aren't running by `oc describe pod/<pod> -n assisted-installer`

  When a pod restarts it is possible for it to have about 3 restarts in case the DB just came up as well because it fails to connect to it until DB is ready, this process shouldn't take more than 5 minutes so we shouldn't get an alert for it from the first place.

- Check for error level logs in the pod.

## Escalations
- Ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert
