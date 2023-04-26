# Onboard an OCM organization into app-interface

Several app-interface features and SRE capabilities revolving around OCM depend on an OCM organization file to identify an organization and define authentication.

This SOP describes the process of adding an `/openshift/openshift-cluster-manager-1.yml` file for a new OCM organization.

## Prerequisites

An owner or member of the organization to be onboarded needs to provide the OCM organization ID. This ID can be aquired by

```sh
ocm whoami | jq .organization.id
```

> ⚠️  OCM service accounts are not necessarily associated with an OCM organization and the above command will not yield any results in such cases. Use a personal account instead to find the organization ID. OCM CLI login instructions and tokens can be found on <https://console.redhat.com/openshift/token>

## Adding the organization file

Create a file under `/data/dependencies/ocm/$tenant/$orgname.yml`

```yaml
---
$schema: /openshift/openshift-cluster-manager-1.yml

labels: {}

name: <org-name> (1)
description: <meaningful description>
environment:
  $ref: /dependencies/ocm/environments/production.yml (1)
orgId: <organization ID>
```

(1) OCM organizations don't have a name but in app-interface we can maintain one for more context in logs
(2) ... or use the staging or integration one depending on the usecase

The [sre-capabilities OCM service account](https://gitlab.cee.redhat.com/service/ocm-resources/-/blob/master/data/uhc-production/users/service-account-sre-capabilities.yaml) is not bound to any organization and has for all relevant cluster and cluster-upgrade permissions in all (⚠️) organizations. Using this account simplifies the onboarding of an OCM organization because no additional SSO account, OCM SA and permissions need to be requested.

If the organization should rely on a dedicated service account (should be rarely the case), dedicated credentials can be specified that take precedence over the ones from the referenced environment:

```yaml
$schema: /openshift/openshift-cluster-manager-1.yml
...
accessTokenClientId: xxx
accessTokenUrl: https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
accessTokenClientSecret:
  path: xxx
  field: client_secret
```
