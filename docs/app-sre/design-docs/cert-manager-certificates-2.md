# ACME certificates with Cert-manager

[toc]

## Author/date

Jordi Piriz / 2020-06-30

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4784

## Problem statement

This design doc is meant to define how openshift-acme is going to be replaced by cert-manager.
Two problems are going to be solved.

1. openshift-acme is abandoned and we can not rely on it anymore
2. We need a way to use ACME certificates (lets-encrypt) in our internal clusters. Internal clusters
   are  not reachable from the internet so the ACME provider can not resolve an HTTP challenge. We will
   rely on DNS challenges for that.

## Goals

- Define the approach we are going to use with cert-manager

## Non-Goals

- N/A

## Proposals

- Install [cert-manager-operator](https://github.com/openshift/cert-manager-operator) along with the brand new support
  for openshift-routes through [cert-manager-openshift-routes](https://github.com/cert-manager/openshift-routes)
- Modify dev-guidelines documentation with the new approach.
- Notifiy tenants to update the Route specs / Track progress
- Remove openshift-acme

### Issuers Configuration

External clusters will still use an HTTP solver. A Cluster wide `ClusterIsser` will be created and used for all the certificates. HTTP solver
is more flexible because the tenants just need to point the DNS name the cluster.

Internal clusters will use DNS solvers. DNS solvers configuration require a Secret with the DNS credentials /Api keys to create the TXT records needed
to  solve the ACME challenge. AppSre managed dns zones (devshift.net) will be set as cluster wide with a selector to act only in the managed domains.
If a tenant wants to use its own domain in an internal cluster, they will need to create/manage the DNS solver configuration in its own namespace with the
`Issuer` crd.

## Alternatives Considered

- [Discussions](https://docs.google.com/document/d/1Io_f26Ph9Yomqmx4K1AJkwoB-TLsw9gECWxOJRa3D7o/edit#heading=h.4c9twulgg922)
- [first design doc](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/design-docs/cert-manager-certificates.md)
  Obsolete since openshift-routes are supported by cert-manager

## Milestones

- Roll out changes in App-sre managed routes.
- Notify tenants
- All certificates used in app-interface are using cert-manager
