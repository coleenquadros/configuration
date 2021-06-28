# Managed Application Service - Single Sign On (MAS SSO)

MAS (Managed Application Services) SSO (Single Sign On) provides authentication and authorization services for Managed Services.
It contains an RH-SSO operator that manages the Keycloak (RH-SSO) instances. The default deployment consists of 3 instances of Keycloak.
AWS RDS - PostgreSQL is used for persistent storage.

![MAS SSO Deployment](./images/MAS-SSO-deployment.png)


## MAS SSO Architecture

![MAS SSO Service Architecture](./images/mas-sso-architecture.png)

This is a simplified view of MAS SSO. It details its interaction with different components in the Managed Kafka ecosystem.
The `sso.redhat.com` is registered as an Identity Provider (IdP), this enables Red Hat customer users to interact with the Managed Kafka service.

- Managed Kafka Service Control Plane
  - Control Plane of the Kafka Service.
  - UI for Kafka cluster
  - "Kas-Fleet-Manager (Kafka Service API) - Public API
  - Kafka Service UI - Terraforming of Kafka clusters, create/delete Kafka cluster
  
- Managed Kafka Service Data Plane
  - Kafka cluster Admin API - This allows performing Kafka admin operations 
    - ex: create/delete a topic

UI and CLI perform authentication across `sso.redhat.com` and `MAS SSO`. They maintain two different tokens.
For the control plane, they would use sso.redhat.com token, and if they want to interact with the data plane MAS SSO token is used.

## MAS SSO - Interaction with the Managed Kafka Control Plane
The below diagram illustrates the control plane authentication flow
![Control Plane authentication flow](./images/control-plane-authentication-flow.png)

- Users are first authenticated against sso.redhat.com - User login
- UI/CLI - custom logic does an Identity brokering login with MAS SSO
  - Users registered with sso.redhat.com are created in MAS SSO behind the scenes
- Users once authenticated can create/delete Kafka clusters from the Kafka UI

TODO - Address comments in [MGDSTRM-4138](https://issues.redhat.com/browse/MGDSTRM-4138)

## MAS SSO - Interaction with the Managed Kafka Data Plane 
The below diagram illustrates the data plane authentication flow
![Data Plane authentication flow](./images/Data-plane-message-flow.png)

- User can request a Service account through the control plane
  - Attributes like Org ID, User ID are added inside the control plane
- Configure the Kafka client 
  - jaas-config is the common one, and it uses the service account that was created
  
SASL plain and SASL OAuth bearer, both mechanisms are supported

Kafka brokers fetch the JWKS certificate and validate the token.

Custom claim check - This was added Kafka specific to restrict the actions on the Kafka cluster
  - configured users Org ID and User ID are used to verify the token claim.
  - At present only the owner of the Kafka cluster can create a service account for that cluster

TODO - Address comments in [MGDSTRM-4138](https://issues.redhat.com/browse/MGDSTRM-4138)

## Routes

The following route is exposed by the service
- Production: `identity.api.openshift.com`
- Staging: `identity.api.stage.openshift.com`
 

## Dependencies

This list of dependencies for MAS SSO 
1. *Cluster Service*: 
   Used for OSD cluster creation, add-on installation, IDP setup, trusted data path (SyncSets), and scaling compute nodes
2. *sso.redhat.com*:
   Identity federation
3. *AWS Route 53*:
   Creation of route for MAS SSO instance
4. *AWS RDS*:
   PostgreSQL database that acts as the datastore for MAS SSO
5. *Let's Encrypyt*:
   Lets Encrypt from ACME is used for certifcate management.

## Twelve-factor compliance
- Codebase: One codebase tracked in revision control, many deploys
  - Yes. [Codebase](https://gitlab.cee.redhat.com/service/saas-mas-sso)
- Dependencies: Explicitly declare and isolate dependencies
  - Done
- Config: Store config in the environment
  - TODO
- Backing services: Treat backing services as attached resources
  - AWS RDS - acts as a datastore for the service, and it is backed up regularly.
- Build, release, run: Strictly separate build and run stages
  - Done
- Processes: Execute the app as one or more stateless processes
  - Done  
- Port binding: Export services via port binding
  - TODO   
- Concurrency: Scale-out via the process model
  - TODO
- Disposability: Maximize robustness with fast startup and graceful shutdown
  - TODO
- Dev/prod parity: Keep development, staging, and production as similar as possible
  - Done
- Logs: Treat logs as event streams
  - Done
- Admin processes: Run admin/management tasks as one-off processes
  - TODO

TODO - Will be covered under [MGDSTRM-3349](https://issues.redhat.com/browse/MGDSTRM-3349)


## Service forecast

TODO - Current capacity and expected forecast [MGDSTRM-3344](https://issues.redhat.com/browse/MGDSTRM-3344)


## State
### Postgres Database

TODO


## MAS SSO Admin Credentials in Vault

### Overview

MAS SSO (Keycloak) instance, requires a secret with admin credentials i.e. admin username and password.
This secret is provided for MAS SSO from the vault (app-interface), through app-interface integrations.

### Usage

The following steps are the recommended way of using this secret
- This secret should only be used for bootstrapping the MAS SSO i.e. the initial admin access.
- MFA authentication should be enabled for all user login, especially admin users.
- Create the relevant admin account(s) as necessary for the team members with the appropriate permissions/roles.
- Disable the admin account that was created via the secret in MAS SSO. This is required for the following reasons:
  - With MFA only one person can use that account, so it is not a shared credential
  - The user account name is pretty generic, and we require non-repudiation. (To know which admin user performed what action and when)
  - For security reasons, since the credential is in a vault, any exposure/leak at the vault would give access to MAS SSO.
- The admin account via the secret should only be used again in a break-glass scenario, i.e. We need access to MAS SSO
  and do not have an admin user credential for any of the admins (locked out).

### Rotation

Even though as per recommendation we disable the admin account from the vault. It is still recommended to rotate the secret in a
periodic way.

- Create a 100 character or more random alphanumeric string that will be used as the admin password.
- Do not use any random string or password generation tools online. CLI tools such as `pwgen` are preferred.
  - Ex: `pwgen -c -n   -s -1  100`



## Alerts and SLOs

We have 4 alerts for [availability](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/mas-sso/sop/mas-sso-availability/mas-sso-availability.md#list-of-alerts) 
and  4 alerts for [latency](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/mas-sso/sop/mas-sso-latency/mas-sso-latency.md#list-of-alerts). The alerts are tied to the service level objectives (SLOs). Alerts definition are based on [multi-window, multi-burn rate](https://sre.google/workbook/alerting-on-slos/) and are unit tested. 

Resources: 

1. https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/prometheusrules all mas-sso-*
2. https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop


## Load Testing

TODO - Covered in [MGDSTRM-3347](https://issues.redhat.com/browse/MGDSTRM-3347)

