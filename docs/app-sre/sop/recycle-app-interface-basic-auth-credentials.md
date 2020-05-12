# Recycle app-interface basic auth credentials

In case we need to recycle the basic auth credentials for app-interface production, these are the secrets to update:
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/app-interface
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/qontract-reconcile-toml
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-ext/qontract-reconcile-toml
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface/production/basic-auth

In addition, submit a MR to app-interface to update the following secret versions:
- https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/app-interface/namespaces/app-interface-production.yml#L43-45
- https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/app-interface/namespaces/app-interface-production.yml#L48-50

You may need to restart all the pods in the app-interface-production namespace.

TODO: improve this!

# Recycle app-interface basic auth developer access

In case we need to recycle the basic auth credentials for app-interface production, these are the secrets to update:
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/app-interface
    * update the 2nd line of the `htpasswd` key
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface/production/basic-auth
    * update the `dev-access` key

In addition, submit a MR to app-interface to update the following secret versions:
- https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/app-interface/namespaces/app-interface-production.yml#L43-45

You may need to restart all the pods in the app-interface-production namespace.
