# App-interface OCM SSO token

App-interface integrations use a [Client Credentials grant type](https://www.appsdeveloperblog.com/keycloak-client-credentials-grant-example/) to login to OCM using an access token obtained from RH SSO.

This document is the result of the work done in [APPSRE-2494](https://issues.redhat.com/browse/APPSRE-2494).

## Service Account details

The credentials belong to an SSO Service Account. The Service Account was requested in this [SNOW ticket](https://redhat.service-now.com/surl.do?n=RITM0792664) (which was replaced with this [Jira ticket](https://issues.redhat.com/browse/ITUSERSVC-2293)) according to the [Request Service Account SOP](/docs/app-sre/sop/sso-redhat-com-sops.md#request-service-account).

The same Service Account is used for OCM stage and production environments, since they both use the same SSO instance.

The credentials are stored in Vault:
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-ocm-bot
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/ocm/sd-app-sre-ocm-app-interface

They are used in the following data files:
- [OCM Production AppSRE org](/data/dependencies/ocm/production.yml)
- [OCM Stage AppSRE org](/data/dependencies/ocm/stage.yml)

## Service Account Roles

Roles are managed in the [ocm-resources](https://gitlab.cee.redhat.com/service/ocm-resources) repository.

These files define the roles granted to the AppSRE Service Account:
- [stage](https://gitlab.cee.redhat.com/service/ocm-resources/-/blob/master/data/uhc-stage/users/service-account-sd-app-sre-ocm-sa.yaml)
- [production](https://gitlab.cee.redhat.com/service/ocm-resources/-/blob/master/data/uhc-production/users/service-account-sd-app-sre-ocm-sa.yaml)

The definitions of these roles can be found in the [AMS repository](https://gitlab.cee.redhat.com/service/uhc-account-manager/-/tree/master/pkg/api/roles). It is preferable to create service specific roles, to assign only the minimum set of permissions needed for the Service Account.

Note that every service account gets the [ServiceAccount](https://gitlab.cee.redhat.com/service/uhc-account-manager/-/blob/master/pkg/api/roles/service_account.go) role assigned automatically, which may cover some use cases: 


## Service Account organization association

Some app-interface integrations require an organization scope. Service Accounts are not automatically associated to an Organization.

To associate a Service Account to an Organization, create a ticket of the SDB board requesting this association.

The AppSRE Service Account was associated to the AppSRE Organization is [SDB-3232](https://issues.redhat.com/browse/SDB-3232).

## Rotate OCM client secret for app-interface integrations

Rotation in not needed on a regular basis, as client credentials (unlike offline token) do not expire.

- Follow the [Client secret rotation SOP](/docs/app-sre/sop/sso-redhat-com-sops.md#client-secret-rotation).
- Update the client secret in the relevant paths in Vault (see details section).
- If the secret is stored in Vault in a KV v2 secret engine, submit a MR to app-interface to bump the version of the secret in the relevant OCM data files (see details section).


## Qontract-reconcile usage

This is where we use the Service Account credentials to authenticate to OCM in [qontract-reconcile](https://github.com/app-sre/qontract-reconcile/blob/83fea5949d1a0841fab3e8eebd8c2c471919c7d2/reconcile/utils/ocm_base_client.py#L34-L44).
