# Design doc: Rover group based OSD/ROSA authorization SRE capability

[toc]

## Author/date

Gerd Oberlechner / May 2023

## Tracking Jira

<https://issues.redhat.com/browse/SDE-2628>

## Problem statement

OCM provides group management functionality for the `cluster-admin` and `dedicated-admin` groups. Cluster owners can add users to those groups via the OCM UI or the OCM CS API. For teams owning a fleet of clusters, adding the same users to multiple clusters and keeping them in sync is considered toil.

## Goals

- keep the `cluster-admin` and `dedicated-admin` groups on a fleet of clusters in sync with a group definition
- offer this functionality as an SRE capability accessible to all of Red Hats engineering teams

## Non goals

- manage arbitrary cluster groups besides the mentioned ones (depends on [SDA-8214](https://issues.redhat.com/browse/SDA-8214))
- offer rover group based cluster group management via app-interface configuration (we will write the code in a way though, that it can be reused for this scenario, e.g. see the AUS approach)

## Proposal

Use a Rover group as the source of users and sync them to the `cluster-admin` or `dedicated-admin` groups of a cluster or a fleet of clusters. Users will be reconciled on a regular basis.

This capability will be a standalone service based on the [OCM label based consumption model](https://service.pages.redhat.com/dev-guidelines/docs/sre-capabilities/framework/ocm-labels) from the [SRE capabilities framework](https://service.pages.redhat.com/dev-guidelines/docs/sre-capabilities/framework).

### Defining group mappings via OCM labels

To define a group mapping, a user places labels with the mapping configuration on the organization and/or subscription of a cluster.

| Label Type   | Label Key                                              | Example             | Notes                                                                                                                          | Mandatory / Default |
|--------------|--------------------------------------------------------|---------------------|--------------------------------------------------------------------------------------------------------------------------------|---------------------|
| Organization | sre-capabilities.rover-group-authz.org-cluster-admin   | app-sre,sd-internal | CSV of Rover group LDAP common names that will be applied to all cluster-admins group of all clusters within an organization   | no / no default     |
| Organization | sre-capabilities.rover-group-authz.org-dedicated-admin | app-sre,sd-internal | CSV of Rover group LDAP common names that will be applied to all dedicated-admins group of all clusters within an organization | no / no default     |
| Subscription | sre-capabilities.rover-group-authz.sub-cluster-admin   | app-sre,sd-internal | CSV of Rover group LDAP common names that will be applied to the cluster-admin group of a cluster                              | no / no default     |
| Subscription | sre-capabilities.rover-group-authz.sub-dedicated-admin | app-sre,sd-internal | CSV of Rover group LDAP common names that will be applied to the dedicated-admin group of a cluster                            | no / no default     |

The Rover groups listed in `sre-capabilities.rover-group-authz.sub*` and `sre-capabilities.rover-group-authz.org` labels are aggregated before being applied to a cluster.

### Reconciler and runtime

The label based reconciler is going to be implemented as a new integration in qontract-reconcile and will be managed by the integrations-manager within the regular app-interface runtime infrastructure. This is in alignment with Milestone 1 of the [SRE capabilities initiative](docs/app-sre/initiatives/sre-capabilities.md).

The [SRE capabilities initiative](docs/app-sre/initiatives/sre-capabilities.md) defines a change in runtime environment for capabilities in Milestone 3. Capabilities will be homed in a dedicated environment that is detached from app-interface.

### Alerting

For the time being, alerting for this capability will follow the qontract-reconcile alerting scheme (tldr: a failing reconcile run will ping app-sre-ic in #sd-app-sre-alert). To adhere to the differences in the support model between integrations and capabilities, this capability will not fail for situations uncovered by the support model, e.g. bad configuration data provided via OCM labels. These situations will be highlighted to users via OCM service logs and will not trigger pages for AppSRE.

### Relationship with cluster AuthN

Usernames from the `cluster-admin` and `dedicated-admin` groups must align with the usernames provided by the cluster authentication mechanism. The preferred way to ensure this for Red Hat usernames is Red Hat SSO via auth.redhat.com. Automating auth.redhat.com authentication setup for OSD/ROSA clusters is going to be handled by a dedicated capability (see [SDE-2620](https://issues.redhat.com/browse/SDE-2620)).

## Milestones

### Milestone 1

- implement the capability as an app-interface integration and deploy via integrations-manager

### Milestone 2

- deploy into a dedicated runtime environment (part of M3 of the initiative)
