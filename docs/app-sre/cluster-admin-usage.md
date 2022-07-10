# Using the cluster-admin role

## Context

AppSRE is considered customer zero of OSD and tries to use OSD the way Red Hat customers do. This implies no or limited use of `cluster-admin` capabilitites.

When qontract-reconcile deploys resources to Openshift clusters, it leverages service account tokens for the API server communication. Each cluster managed that way via app-interface defines respective Vault secret references in the `/openshift/cluster-1.yml` schema.

`automationToken` references a token with `dedicated-admin` privileges which has the capabilities to create namespaces and workloads along with cluster settings read permissions.

`clusterAdminAutomationToken` on the other hand references a token with `cluster-admin` privileges which has full administrative access to an OSD cluster.

Please note, that those are only conventions and `automationToken` could hold an arbitrary token that potentially holds more permissions, e.g. fedramp OSD clusters having `cluster-admin` permissions. Also, not all app-interface managed cluster have a `clusterAdminAutomationToken` defined.

## How to use cluster-admin

Before starting to use `cluster-admin` carefully consult the sections about when `cluster-admin` can be used and when not!

The placement of resources onto an Openshift cluster via `/openshift/namespace-1.yml#openshiftResources` or via `/app-sre/saas-file-2.yml` leverages the non-privileged `automationToken` by default. Both schemas offer a `clusterAdmin: true` option to switch to the `clusterAdminAutomationToken`.

MRs, enabling `cluster-admin` for a namespace or a SAAS file must be carefully reviewed and must be accompanied with restrictive `managedResourceTypes` and `managedResourceNames` settings.

## When to use cluster-admin

For almost all resource placement scenarios, `cluster-admin` permissions are not required. The service account with `dedicated-admin` permissions can create namespaces (except for `openshift-*` named ones) and place resources into them.

If `cluster-admin` permissions are required, their use must be limited to the following scenarios:

- installation of operators with CRDs and cluster RBAC, when OLM can't be used

## When not to use cluster-admin

While the previous section explicitely named allowed `cluster-admin` scenarios, the purpose of the following list is to give more insights about what we explicitely don't want to use `cluster-admin` privileges for.

- We must not use `cluster-admin` permissions to change cluster settings explicitely managed by SREP. If unsure consult SREP ask AppSRE team members. If a general requirement to manage certains setting arises, they must be discuss with SREP.
- We must not use `cluster-admin` permissions for tasks that can be accomplished via OCM, e.g. cluster upgrades, ingress controller settings, etc. If a general functionality not covered by OCM becomes necessary, consult with SDA/SDB.
