# Assisted Installer Cluster Installation Errors

## Severity: Medium

## Impact
- Users are unable to deploy new bare-metal OpenShift clusters using Assisted Installer

## Summary
Assisted-installer based cluster installation fails to complete.

## Access required

- Access to the cluster that runs the assisted-service Pod
- View access to the namespaces:
  - assisted-installer

## Steps
- Check the production endpoint:

    `curl https://api.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"`

   => Both might return `[]` if you never created any clusters
   
- Check that the Pods are running in the `assisted-installer` Namespace on the `app-sre-prod-04` cluster.

## Escalations
- Ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert
