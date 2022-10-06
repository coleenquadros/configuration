# Cloudflare

[TOC]

## Overview

AppSRE enables users to provision Cloudflare resources as part of their service architecture

The currently supported Cloudflare services are:
- Zones (records)
- Argo
- Workers (routes, scripts)

We support any account tier (Free, Business, Enterprise) but certain resources or parameters requires higher tier accounts to be enabled. Refer to Cloudflare's [account plans overview](https://www.cloudflare.com/en-ca/plans/#overview) or the [cloudflare terraform module docs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs) for more details

## Architecture

### Accounts

Cloudflare accounts are defined in app-interface using the `/cloudflare/account.yml` schema

Cloudflare resources are defined per namespaces via [externalResources definitions](https://gitlab.cee.redhat.com/service/app-interface#manage-external-resources-via-app-interface-openshiftnamespace-1yml)

Information regarding the supported resources and their schemas can be found in the [graphql definitions in qontract-schemas](https://github.com/app-sre/qontract-schemas/blob/main/graphql-schemas/schema.yml)

Additional information on specific resource parameters can be found in the [cloudflare terraform module docs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)

## Metrics and Dashboards

TBD

## Troubleshooting

### Dashboard access

[Cloudflare Dashboard](https://dash.cloudflare.com/)

Credentials to Cloudflare accounts can be found in [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/cloudflare). The table below describes which user has access to which account.

| User email                               | Accounts                             |
|------------------------------------------|--------------------------------------|
| sd-app-sre+cloudflare-app-sre@redhat.com | app-sre<br/>quay-stage<br/>quay-prod |


The 2FA TOTP codes for each account can be retrieved from Vault. The exact path to query is defined under the `2fa_code` key under each account (DO NOT use the recovery codes, except under an emergency situation)

Example
```sh
vault login -method=github -address=https://vault.devshift.net
vault read totp/app-sre/code/sd-app-sre+cloudflare-app-sre
```

### Enterprise support

**Non-critical production issues**
* For reactive and immediate responses: Open a support ticket via the Cloudflare Dashboard under the Support / Contact Support menu
* Email 24/7 Enterprise support team at entsupport@cloudflare.com
  * Support team will review emails only from registered account users
* Web chat via the Cloudflare Dashboard

**24/7 Emergency line**
* North America: +1 (650) 353-5922
* UK: +44 808-169-9540
* Singapore: +65 800-321-1182
* Additional info can be found at the [Enterprise Customer Portal](cloudflare.com/ecp/overview/) (need to be logged in to the account)

Security verification is mandatory to receive enterprise support. Such verification is done via a `Single-use token` which can be retrieved via the Cloudflare dashboard, under Contact Support / Get Single-use token

## SOPs

### Creating a new Cloudflare account

Cloudflare doesn't support email sub-addressing, so we cannot have a unique user login per account. Follow the steps below only if there isn't already a system account setup that would be appropriate for this use case.

- Go to https://dash.cloudflare.com/sign-up
- Enter desired user & password
  - Email: appropriate team address, again sub-addressing isn't supported
  - Password: generate something secure
- Complete email verification
- Enable 2FA
  - Login to the account
  - Go to "My Profile"
  - Go to "Authentication"
  - Click "Enable 2FA"
  - [Add the 2FA to vault](https://gitlab.cee.redhat.com/service/app-interface#manage-vault-secret-engines-vault-configsecret-engine-1yml)

The steps below are followed for new accounts whether there is an existing user login or not:

- Invite the system account user
  - This will generally be done by the Cloudflare team, just provide them with the email that you'd like to use
- Create an API Token for use by the integration
  - Login to the account
  - Go to "My Profile"
  - Go to "API Tokens"
  - Click "Create Token"
  - Set up the token with the following permissions:
    - Account: Billing: Edit
    - Account: Worker Scripts: Edit
    - Zone: Zone: Edit
    - Zone: SSL and Certificates: Edit
    - Zone: Zone Settings: Edit
    - Zone: Workers Routes: Edit
    - Zone: DNS: Edit

## Helpful links & resources

[Cloudflare status page](https://www.cloudflarestatus.com/)

Enterprise account contacts:

| Name           | Email                   | Role                        |
|----------------|-------------------------|-----------------------------|
| Tim Flynn      | tflinn@cloudflare.com   | Customer Success Manager    |
| Tom Hammell    | thammell@cloudflare.com | Field Solutions Engineer    |
| Brian Ceppi    | bceppi@cloudflare.com   | Enterprise Account Manager  |
| Rick Fernandez |                         | Customer Solutions Engineer |
