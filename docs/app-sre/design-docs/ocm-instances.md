# Design document - OCM instances and organizations within app-interface

## Author / Date

Gerd Oberlechner / March 2023

Jira [APPSRE-7281](https://issues.redhat.com/browse/APPSRE-7281)

## Problem statement

The `/openshift/openshift-cluster-manager-1.yml` schema hybridly declares OCM environments and OCM organizations. This blurs the line what parts belong to an environment and which ones to an organization. Integrations that deal mostly with an OCM environment have no clear schema that identifies such an environment in a unique way.

## Goals

* clearly identify an OCM environment within `app-interface` and resolving the hybrid OCM environment/org schema problem

## Non-goal

* define support levels for OCM environments and OCM organizations
* align alerting strategies for failing integrations based on environment and organization support levels

Support level definitions and alerting for environments and organizations will be handled within the scope of [APPSRE-7289](https://issues.redhat.com/browse/APPSRE-7289)

## Proposal

Introduce a new schema `/openshift/openshift-cluster-manager-environment-1.yml` that represents an OCM environment (integration, stage, production). This schema includes the API base URL and authentication information to be used when interacting with the OCM environment (e.g. for SRE capabilities).

```yaml
$schema: /openshift/openshift-cluster-manager-environment-1.yml

name: ocm-production
description: OpenShift Cluster Manager Production Environment

url: https://api.openshift.com

accessTokenClientId: xxx        (1)
accessTokenUrl: https://xxx
accessTokenClientSecret:
  path: path/to/secret
  field: client_secret
```

(1) the credentials to be used when interacting with the OCM environment in the context of SRE capabilities

> To improve our security posture, different credentials should be used to different environments and organizations. That can be enforced on the schema once we have service accounts in place.

The `/openshift/openshift-cluster-manager-1.yml` schema will reference a `/openshift/openshift-cluster-manager-environment-1.yml` and will not declare `url` anymore. Authentication information will be optional.

* If they are missing, the credentials from the referenced OCM environment will be used. This is the proposed way for OCM organizations that are onboarded to `app-interface` in the context of SRE capabilitites.
* If they are defined, they are used in favour over the ones from the OCM environment. This is the proposed way for AppSRE managed OCM organizations or for organizations where very special permissions bound to a specific service account are required.

```yaml
$schema: /openshift/openshift-cluster-manager-1.yml
name: my-org
environment:
  $ref: <ref-to-ocm-environment>
orgId: xxx
accessTokenClientId: xxx     (1)
accessTokenUrl: https://xxx  (1)
accessTokenClientSecret:     (1)
  path: path/to/secret
  field: client_secret
```

(1) optional - defaults to the respective fields in the referenced OCM environment

## Milestones
