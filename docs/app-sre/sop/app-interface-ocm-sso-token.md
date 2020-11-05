# Refresh OCM offline tokens for app-interface integrations

Offline tokens are used by app-interface integrations to login to OCM. Sometimes it may be necessary to refresh them because they expired.

OCM integrations data files:
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/ocm/sd-app-sre-ocm-app-interface
- https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ocm/stage.yml

Credentials:
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-ocm-bot

Offline token:
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/ocm/sd-app-sre-ocm-app-interface

## Configuring a new offline token

Note: We are using the same account for both production and staging. The offline token is also the same.

1. Login to https://cloud.redhat.com/openshift with the above credentials

1. Navigate to https://cloud.redhat.com/openshift/token

1. Copy the token to the above Vault secret. There is no need to restart anything as the OCM integrations will pick up the new token on subsequent runs

