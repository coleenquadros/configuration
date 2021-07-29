# Service Migration (or: How to migrate a service between clusters)

## Background

In some scenarios, we are required to migrate services between clusters.

## Purpose

This is an SOP to list the actions to be performed to migrate a service between clusters.

* Note: a service may be deployed in a single namespace or in multiple. This SOP illustrates a service in a single namespace, but instructions should be roughly the same for multiple namespaces.

## Considerations in migrating a service

1. Check if the service communicates to other services on the same cluster. If so, should the 2 services be colocated? This may indicate that to migrate service A, service B should also be migrated. Suspect this is the case when there is a `networkPoliciesAllow` section in the namespace to a namespace different `openshift-customer-monitoring`.
1. Check if the service communicates to other services in a different cluster. This may mean that a VPC peering should be set up prior to the migration of the service.
1. Check if the service communicates to external resources, such as RDS. This may mean that a VPC peering and Security Group rules should be set up prior to the migration of the service.
    * Note: moving a terraform resource (such as RDS) between namespaces is safe and only changes tags on the resource in AWS.
1. Check if the service has DNS entries (either managed by SREP or by app-interface). This means that the service migration will include DNS updates.
1. Check if the service can run in parallel in different clusters. Some things to look for: Is the service using a DB? If so, how are DB migrations performed (DB locking)? If the service can not run in parallel, a migration would probably mean down time for the migration.
1. Check if the service requires static egress IPs to talk with any other services, such as those inside the VPN. New IPs will be issued.
   * Note, OCM is one of the services that requires this for communication with the RH UMB: [OCM HA Setup](/docs/app-sre/sop/ocm-ha-setup.md:45)

## What to expect

The process from a high-level perspective is: setup, move, cleanup. The optimal way to migrate a service is "here-and-now" (i.e. don't take your time and do this migration over 3 months). The process describes the move of a namespace between clusters, and not the copy and parallel run of a service on 2 clusters.

The critical part of the migration is moving a namespace between clusters. a Merge request to do this action is very simple and includes only very few changes (change cluster ref and observability namespace network policy), but a lot is happenning behind the scenes.

Once the merge request is merged, the deployment jobs will be triggered. This is not optimal, but these jobs are triggered quickly (by design). At this point, some resources may already be deployed, but they are not expected to work. It is possible that the namespace on the target cluster does not exist yet, but the deployment jobs take that into account. Our integrations (openshift-resources, terraform-resources, etc), which are not as quick, will start applying required resources into the namespace after the deployment jobs. Most of these resources will cause pods to be restarted, which means that the state in the new namespace will be eventually consistent.

At this point, the namespace on the source cluster still exists with the service running in it, but it is not managed by app-interface any longer. This is the main reason to migrate "here-and-now" (since we are moving resources in app-interface, the integrations will lose track of the namespace in the source cluster and things will not get deleted).

* Note: the other option would be do duplicate _a lot_ of resources, which is not beneficial in the writer's perspective.

## Migration process

* Note: as this SOP is in an early state, it does not have exact steps and examples for each step. All steps should be performed through app-interface merge requests, unless otherwise explicitly mentioned.

1. Create any required VPC peerings. This may require adding AWS Infrastructure access. More information: [OSDv4 cluster VPC peerings with existing AWS account](/docs/app-sre/sop/app-interface-cluster-vpc-peerings.md)
1. Copy (NOT move) observability resources (`openshift-customer-monitoring` namespace) from the source cluster to the target cluster.
1. Move (NOT copy) the service's namespace to the target cluster and update Network policies. More information: [Enable network traffic between Namespaces via App-Interface](https://gitlab.cee.redhat.com/service/app-interface#enable-network-traffic-between-namespaces-via-app-interface-openshiftnamespace-1yml)
1. Validate service is operational on the target cluster. This should optimally be done with [Continuous Testing in App-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-testing-in-app-interface.md).
1. Shift DNS to the target cluster. More information: [Manage DNS Zones via App-Interface](https://gitlab.cee.redhat.com/service/app-interface#manage-dns-zones-via-app-interface-awsdns-zone-1yml-using-terraform).
1. Delete observability resources from the source cluster.
1. (Manually) scale down the service in the source cluster (and eventually (manually) delete the namespace).
