# Onboard an OCM organization into app-interface

Several app-interfaces feature and SRE capabilities revolving around OCM depend on an OCM organization file to identify an organization and define authentication.

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

name: <org-name>
description: <meaningful description>
url: "https://api.openshift.com" (1)

orgId: <organization ID>
accessTokenClientId: sre-capabilities (2)
accessTokenUrl: https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
accessTokenClientSecret:
  path: app-sre/creds/ocm/sre-capabilities
  field: client_secret
```

(1) Depending on the OCM environment, use one of the following

* production <https://api.openshift.com>
* stage <https://api.stage.openshift.com>
* integration <https://api.integration.openshift.com>

(2) The [sre-capabilities OCM service account](https://gitlab.cee.redhat.com/service/ocm-resources/-/blob/master/data/uhc-production/users/service-account-sre-capabilities.yaml) is not bound to any organization and has for all relevant cluster and cluster-upgrade permissions in all (⚠️) organizations. Using this accounts simplifies the onboarding of an OCM organization because no additional SSO account, OCM SA and permissions need to be requested.
