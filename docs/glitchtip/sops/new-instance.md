# Onboarding a new Glitchtip Instance

## Create admin and qontract-reconcile accounts

All API users are stored in Vault and created/reconciled by the [glitchtip-web deployment](https://github.com/app-sre/glitchtip/blob/main/openshift/template.yaml#L194) during the startup. For a new instance, save the new credentials in [vault](https://vault.devshift.net/ui/vault/secrets/app-interface/list/app-sre/glitchtip/):

**users**
1. Create an `admin` account to log in to the Glitchtip Django admin interface.
   1. `email = sd-app-sre+glitchtip-admin@redhat.com` and
   1. `password` generate one using a password manager or `python -c 'import secrets; print(secrets.token_urlsafe(24))'`
1. Create a `qontract-reconcile` account for the glitchtip q-r integration.
   1. `email = sd-app-sre+glitchtip@redhat.com`
   1. `token` generate one (less 64 chars) using a password manager or `python -c 'import secrets; print(secrets.token_urlsafe(63))'`
1. Create an `observability` account for prometheus.
   1. `email = sd-app-sre+observability@redhat.com`
   1. `token` generate one (less 64 chars) using a password manager or `python -c 'import secrets; print(secrets.token_urlsafe(63))'`

**secret_key**
1. Generate a new Django `secret_key` using `python -c 'import secrets; print(secrets.token_urlsafe(128))'`

## Create a Glitchtip App-Interface Instance

Create a new Glitchtip instance file, e.g., [glitchtip-production instance](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/glitchtip/glitchtip-production.yml):

```yaml
---
$schema: /dependencies/glitchtip-instance-1.yml
labels: {}

name: glitchtip-<INSTANCE-NAME>
description: glitchtip-<INSTANCE-NAME> access information
consoleUrl: <GLITCHTIP-URL>

automationUserEmail:
  path: <VAULT-PATH-TO-QONTRACT-RECONCILE-SECRET created above>
  field: email
  version: 1
automationToken:
  path: <VAULT-PATH-TO-QONTRACT-RECONCILE-SECRET created above>
  field: token
  version: 1
```
