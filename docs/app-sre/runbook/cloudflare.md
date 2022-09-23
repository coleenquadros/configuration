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

### Access

[Cloudflar Dashboard](https://dash.cloudflare.com/)

Credentials to Cloudflare accounts can be found in Vault at https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/cloudflare

The 2FA TOTP codes for each account can be retrieved from Vault. The exact path to query is defined under the `2fa_code` key under each account (DO NOT use the recovery codes, except under an emergency situation)

Example
```sh
vault login -method=github -address=https://vault.devshift.net
vault read totp/app-sre/code/sd-app-sre+cloudflare-app-sre
```

## SOPs

### Creating a new Cloudflare account

- Go to https://dash.cloudflare.com/sign-up
- Enter desired user & password
  - Email: sd-app-sre+cloudflare-SOMETHING@redhat.com
  - Password: generate something secure
- Check emails sent to the sd-app-sre mailing list for an email verification email. Click the link
- Enable 2FA
  - Login to the account
  - Go to "My Profile"
  - Go to "Authentication"
  - Click "Enable 2FA"
  - [Add the 2FA to vault](https://gitlab.cee.redhat.com/service/app-interface#manage-vault-secret-engines-vault-configsecret-engine-1yml)
- Create an API Token for use by the integration
  - Login to the account
  - Go to "My Profile"
  - Go to "API Tokens"
  - Click "Create Token"
  - Set up the token with the following permissions:
    - Account: Worker Scripts: Edit
    - Zone: Edit
    - Zone Settings: Edit
    - Workers Routes: Edit
    - DNS: Edit

## Known Issues

TBD
