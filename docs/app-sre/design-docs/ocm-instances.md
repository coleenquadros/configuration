# Design document - OCM instances and organizations within app-interface

## Author / Date

Gerd Oberlechner / March 2023

Jira [APPSRE-6629](https://issues.redhat.com/browse/APPSRE-7281)

## Problem statement

`app-interface` has several integrations that interact with different OCM environments (integration, stage, prod) and OCM organizations (AppSRE stage and prod, OSD fleet manager integration, stage and prod).

Currently `app-interface` treats all of them the same and AppSRE is paged for issues in all of them equally, while at the same time not all of those environments and organizations are of the same criticality for AppSREs support mandate. Issues in OCM stage and integration should not trigger an oncall situation, while OCM production does. Issues within the AppSRE OCM organizations can indicate critical situations for AppSREs managed clusters, while other OCM organizations might not.

Within the scope of SRE capabilities, even more new organizations will be onboarded to `app-interface` where AppSRE is not going to provide oncall support.

Additionally, `/openshift/openshift-cluster-manager-1.yml` is a schema that hybridly declares OCM environments and OCM organizations. This blures the line what parts belong to an environment and which ones to an organization.

## Goals

* define support levels for OCM environments and OCM organizations
* align alerting strategies for failing integrations based on environment and organization support levels
* clearly identify an OCM environment within `app-interface` and resolving the hybrid OCM environment/org schema problem

## Proposal

Introduce a new schema `/openshift/openshift-cluster-manager-environment-1.yml` that represents an OCM environment (integration, stage, production). This schema includes the API base URL and authentication information to be used when interacting with the OCM environment (e.g. for SRE capabilities). Additionally it declares the support level that that OCM environment.

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

support: <support-level>        (2)
```

(1) the credentials to be used when interacting with the OCM environment in the context of SRE capabilities

(2) the support level on an OCM environment defines how involved AppSRE will be in providing support for this environment and how/if alerts are fired for failing integrations / capabilities

For `critical` support level, failing integrations will reach AppSRE oncall and [AppSRE SLOs](https://gitlab.cee.redhat.com/app-sre/contract/-/tree/master/#appsre-service-level-objectives) apply.

For `best-effort` support level, failing integration will not reach AppSRE oncall and SRE capabilities SLOs will apply (see this [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/60997/diffs#1be6e87e099742f47ad6fc864ab46af673095a07) for preliminary definitions).

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
support: <support-level>     (2)
```

(1) optional - defaults to the respective fields in the referenced OCM environment

(2) defined identically as in the `/openshift/openshift-cluster-manager-environment-1.yml` schema.

## Milestones
