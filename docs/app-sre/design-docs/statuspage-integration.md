# Design doc: status page component automation

## Author/date

Gerd Oberlechner / 2021-11-08

## Tracking JIRA

https://issues.redhat.com/browse/SDE-1493

## Problem Statement

Onboarding app-interface services into the status page (e.g. status.redhat.com) is currently a manual task defined in
the ROMS process.

## Terminology and boundary conditions

A service or technical/architectural aspect of service is represented on a status page as `status page component`,
tracking its state and history. All components on Red Hat's public status pages must be customer facing and recognizable
by a big audience. Red Hat uses the status page product from Atlassian.

Components can optionally be grouped. https://status.redhat.com enforces grouping by public redhat.com domains, e.g.
console.redhat.com. Groups are not nestable. Component groups rarely change and new groups require alignment with the
status page owner.

## Goals

Tenants should be able to configure status page components in app-interface as part of their service contract. The
creation and deletion of the status page components must be automated.

## Non-objectives

The following aspects not subject of this design doc, but will be addressed in future ones

* Automated creation of CatchPoint configurations
* Automated creation of status page component groups
* Automated status ingestion for status page components via monitoring
* Manual status ingestion for status page components via app-interface

## Proposal

We will introduce an app-interface schema `dependencies/status-page-1.yml` to reference a status page. This schema must
define all required information to be able to reach out to a status page provider, authenticate, query and modify
configuration. The schema will include

* an API URL
* a page identifier
* a reference to a Vault secret for authentication

It is AppSREs responsibility to maintain `dependencies/status-page-1.yml` manifests.

While `dependencies/status-page-1.yml` describes a target for a status component to be placed on,
`dependencies/status-page-component-1.yml` will be the new schema to represent the actual status page component. It will
contain the following fields

* reference to a `dependencies/status-page-1.yml`
* a name
* a description
* an optional reference to a component group on the status page
* handling guidance for AppSRE during incidents (e.g. when to flip the status)

It is the responsibility of app-interface tenants to declare `dependencies/status-page-component-1.yml` manifests as part of
their service contract.

To attach one or more `dependencies/status-page-component-1.yml` manifests to a service definition, a new field
`statusPageComponents` will be added to the `app-sre/app-1.yml` schema. This field will be optional to provide backward
compatibility and will be defined as a list of references to `dependencies/status-page-component-1.yml` manifests.

A new integration `status-page-components` will take care of automated creation and deletion of status page components.

We will provide documentation on the app-interface dev guidelines how to submit a status page component in
app-interface, how to name it and under what conditions a status page component can be added (see terminology and
boundary conditions section). Additionally, review documentation will be provided for AppSREs in the
[app-interface-review-process SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-review-process.md).

## Details

The reconcile process must be able to match components on the status page (current state) and declarations in
app-interface (desired state) with each other, in order to decide on the appropriate reconcile actions. Each component
has an identifier returned by the status page API, which can be MRed back into
the `dependencies/status-page-component-1.yml` manifest upon creation (see also alternatives).

Since https://status.redhat.com is not only hosting components managed by app-interface, the component deletion process
needs to be implemented with extra care. The integration will state management to find out if a previously
app-interface managed component has been removed from app-interface and can delete it from the status page.

The order of the components in the `statusPageComponents` field in `app-sre/app-1.yml` is considered when creating new components.
Since the status page is maintained by various parties, the order of existing components will not be touched. When a new
component is added to a service with no prior components, they will be added at the end of the status page or group. If
a new component is added to a service that already has components defined, the new component will be added relative to
the existing ones.

## Alternatives considered

While qontract-reconcile state management (S3 bucket) could be used for component identifier tracking, having the
identifier in app-interface also allows for a straightforward adoption of existing status page components.

## Milestones

As a first step to prove feasability for adoption by tenants, the RHOSR team will use the new schema to create a new
component on https://status.redhat.com (see [APPSRE-4009](https://issues.redhat.com/browse/APPSRE-4009)) and AppSRE will use
the [updates in the app-interface review guide](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-review-process.md)
to check for plausibility.

Following this first step, we will ask tenants to introduce their existing status page components into app-interface
based on the documentation in the [dev guidelines](https://service.pages.redhat.com/dev-guidelines).