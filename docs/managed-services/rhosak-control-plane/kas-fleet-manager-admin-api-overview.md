# Admin API overview

KAS Fleet Manager in the Stage and Production environments provides a set of
privileged endpoints only intended to be used by administrator of the Fleet
Manager. The reason for that is that these endpoints allow
performing potentially destructive actions, actions that should only be
performed by Fleet Manager administrators, accessing sensitive information
and accessing cross-tenant information. This set of endpoints are also often
referred to as Admin API endpoints.

This document explains the particularities of how the Admin API has
been configured for the RHOSAK Stage and Production environments.

First, to get an understanding of how the Admin API works in KAS Fleet Manager,
independently of the RHOSAK Stage and Production particularities,
see the [upstream Admin API overview documentation](https://raw.githubusercontent.com/bf2fc6cc711aee1a0c2a/kas-fleet-manager/main/docs/admin-api-overview.md).

## Defined Admin API RBAC roles

In the case of RHOSAK Stage and Production the following RBAC roles
are defined:
* `kas-fleet-manager-admin-read-<environment>`: Gives "read" (HTTP GET)
   permissions on the Admin API endpoints
* `kas-fleet-manager-admin-write-<environment>`: Gives "read" and "update"
   (HTTP GET and PUT) permissions on the Admin API endpoints
* `kas-fleet-manager-admin-full-<environment>`: Gives "full" permissions
   (HTTP GET, PUT and DELETE) on the Admin API endpoints

Where `<environment>` is either `stage` or `prod`.

The RBAC roles and their mapping to the HTTP Methods of the Admin API endpoints
are configured in the
[KAS Fleet Manager SaaS template](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/managed-services/cicd/saas/saas-kas-fleet-manager.yaml)
for each environment. Specifically, by setting the `ADMIN_AUTHZ_CONFIG` OCP
Template Parameter.

## Mapping of Red Hat SSO Users to Admin API RBAC Roles

In RHOSAK Stage and Production, The internal Red Hat SSO (https://auth.redhat.com)
is configured in KAS Fleet Manager as the authorization server that performs
issuing of OIDC tokens for the Admin API endpoints. Specifically, in the
`EmployeeIDP` OIDC realm.

Due to that, the Red Hat users allowed to interact with the Admin API endpoints
must be the employees' corresponding Red Hat Users.

Additionally, the Red Hat Users interacting with the Admin API endpoints must
have a set of assigned Admin API RBAC Roles depending on what Admin API endpoint
is being called.

The assignment of the Admin API RBAC Roles to Red Hat SSO Users in RHOSAK
Stage and Production is performed through
[Red Hat Rover Groups](https://rover.redhat.com/groups).

Specifically, the following Red Hat Rover Groups are defined and are related
to the KAS Fleet Manager Stage and Production Admin API endpoints:
* `kas-fleet-manager-admin-read-<environment>`: Gives "read" (HTTP GET)
   permissions on the Admin API endpoints
* `kas-fleet-manager-admin-write-<environment>`: Gives "read" and "update"
   (HTTP GET and PUT) permissions on the Admin API endpoints
* `kas-fleet-manager-admin-full-<environment>`: Gives "full" permissions
   (HTTP GET, PUT and DELETE) on the Admin API endpoints

Where `<environment>` is either `stage` or `prod`.

Each Rover Group can be assigned a set of "Members" and "Owners", which are
Red Hat Users. You can see the currently assigned owners for the previously
described Red Hat Rover Groups by searching the `kas-fleet-manager` keyword in the
[Red Hat Rover Groups search page](https://rover.redhat.com/groups/search?q=kas-fleet-manager).

Already existing "Owners" of a given Rover Group are shown under
the `Owners` column in the search results.

Already existing "Members" of a given Rover Group are shown by viewing the
details of the Rover Group. To do so, press the the
Rover Group's `LDAP Common Name` corresponding column value.

As you can see, the defined Red Hat Rover Groups have the same names
as the [Defined RBAC roles](#admin-api-overview) for the Stage and Production
KFM Admin Endpoints. However, they are independent.

A mapping mechanism is involved to assign a set of KFM Admin API RBAC Roles
to Red Hat Users. This mapping mechanism is outlined below.

To describe the mapping mechanism some additional context is needed first:
* A Rover Group ends up being an LDAP group in Red Hat's LDAP system
* Each Employee's Red Hat User is an LDAP user. An employee's Kerberos Username
  is the same as its corresponding LDAP user

When a Red Hat User is added to a Rover Group the corresponding Red Hat User's
LDAP user is added as a member of the corresponding Rover Group's LDAP group.

Then, when a Red Hat User
[Retrieves an OIDC token for the Admin endpoints](#retrieving-an-oidc-token-for-the-admin-endpoints),
Red Hat SSO checks the LDAP groups that the user is a member of.
The resulting group names list are added as part of the JWT token claims
of the retrieved OIDC token. Specifically, in a `.realm_access.roles` array.

Due to the Red Hat Rover Group names that were defined have the same names
as the [Defined RBAC roles](#defined-rbac-roles), when the retrieved OIDC token
is passed to KAS Fleet Manager Stage/Production, the `.realm_access.roles`
array values contain valid values for the Defined RBAC roles. Those roles
are then used by KAS Fleet Manager to allow/deny access for the performed
request to an Admin API endpoint. If that JWT
claim does not exist or it does not contain any of the defined RBAC
roles described above then Fleet Manager assumes no RBAC roles are
provided and the request will be unauthorized.

### Assign KFM Admin API RBAC roles to a Red Hat User

To assign one or more of the [Defined RBAC roles](#defined-rbac-roles) to a Red
Hat User, ask one of the "Owners" of its corresponding Rover Group to add the
desired Red Hat User to that group, either as an "Owner" or as a "Member". Owners
of a Rover Group can add and delete other Red Hat Users to/from that Group so
so the assignment of a User as an "Owner" should be decided with caution.

If your Red Hat user is an Owner of a Rover Group and you want to add
other members/owners to it you can edit the group and add the desired
new members/owners. To see how to do so follow the `Adding Members` section
of the
[Edit a Rover Group](https://source.redhat.com/groups/public/rover/rover_help/rover__groups__edit_a_group_change_membership_description_or_owner)
documentation.

To get more context about the available Rover Groups, who are the Members
and Owners of those groups and how do the Rover Groups map to the defined
KFM Admin API RBAC roles see
[Mapping of Red Hat SSO Users to RBAC Roles](#mapping-of-red-hat-sso-users-to-rbac-roles).

## Retrieving an OIDC token for the Admin API endpoints

To retrieve an OIDC token from the `EmployeeIDP` internal Red Hat SSO's OIDC
realm read the
[Invoking Kafka Admin Endpoints](https://github.com/bf2fc6cc711aee1a0c2a/kas-sre-sops/blob/main/sops/kafka/invoking_kafka_admin_endpoints.asciidoc) SOP.

## Interacting with the Admin API endpoints

To be able to interact with the Admin API endpoints the following steps are
needed:
1. Assign the desired KFM Admin API RBAC roles for your Red Hat User, if it has
   not been done already. See [Assign KFM Admin API RBAC roles to a Red Hat User](#assign-kfm-admin-api-rbac-roles-to-a-red-hat-user)
1. Retrieve an OIDC token for your Red Hat User. See
   [Retrieving an OIDC token for the Admin API endpoints](#retrieving-an-oidc-token-for-the-admin-api-endpoints)
1. Perform an Admin API endpoint request to the desired KAS Fleet Manager
   environment, passing the previously retrieved OIDC token as part of the
   request. See the
   [Invoking Kafka Admin Endpoints](https://github.com/bf2fc6cc711aee1a0c2a/kas-sre-sops/blob/main/sops/kafka/invoking_kafka_admin_endpoints.asciidoc)
   SOP for examples on calling KFM Admin API endpoints against the KFM production
   environment.
