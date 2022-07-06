# Onboarding new application

This SOP documents the process of defining a new pre-shared key to be used by a ConsoleDot application for authentication with the Playbook Dispatcher service.

## Prerequisites

The [playbook-dispatcher role](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/insights/roles/playbook-dispatcher.yml) is required in order to execute this SOP.

## Procedure

1. Log in to [Vault](https://vault.devshift.net/ui/vault/secrets)
1. Identify the correct environment-specific playbook-dispatcher path
   - [secrets/insights-stage/playbook-dispatcher-stage/](https://vault.devshift.net/ui/vault/secrets/insights/list/secrets/insights-stage/playbook-dispatcher-stage/) for stage
   - [secrets/insights-prod/playbook-dispatcher-prod/](https://vault.devshift.net/ui/vault/secrets/insights/list/secrets/insights-prod/playbook-dispatcher-prod/) for prod

1. Generate a new pre-shared key using the Vault's [random](https://vault.devshift.net/ui/vault/tools/random) tool.
   The new key should be a 128-byte number encoded as base64.

1. Nested under the identified path, create a new secret:
   - the secret should be named `auth-psk-<app name>` where `<app name>` is the name of the application that will be using this pre-shared key
   - store a new key/value pair
     - use `key` as the key name
     - use the generated pre-shared key as the value

1. Use app-interface to reference the newly-created secret from a Kubernetes secret in the relevant Playbook Dispatcher namespace ([stage](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/playbook-dispatcher/namespaces/stage.yml), [prod](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/playbook-dispatcher/namespaces/prod.yml)).
   Specifically, under `openshiftResources` define a new entry:

   ```yaml
   - provider: vault-secret
     path: insights/secrets/insights-<environment>/playbook-dispatcher-<environment>/auth-psk-<app name>
     version: 1
   ```

   where
     - `<environment>` is the given environment (stage or prod)
     - `<app name>` is the name of the new application, as defined above

1. Verify, that the a network policy allowing the new application to access the given Playbook Dispatcher namespace exists in the `networkPoliciesAllow` definition. ([stage](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/playbook-dispatcher/namespaces/stage.yml), [prod](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/playbook-dispatcher/namespaces/prod.yml)).
   If it does not, add a new entry.

1. Modify the [ClowdApp definition of Playbook Dispatcher](https://github.com/RedHatInsights/playbook-dispatcher/blob/master/deploy/clowdapp.yaml) to add a reference to the new secret.
   Add

   ```yaml
   - name: PSK_AUTH_<app name>
     valueFrom:
       secretKeyRef:
         key: key
         name: auth-psk-<app name>
         optional: true
   ```

   to the definition of environment variables.

1. Use app-interface to import the newly-created secret as a Kubernetes secret in the relevant namespace of the client service.
   Specifically, under `openshiftResources` define a new entry:

   ```yaml
   - provider: vault-secret
     path: insights/secrets/insights-<environment>/playbook-dispatcher-<environment>/auth-psk-<app name>
     name: psk-playbook-dispatcher
     version: 1
   ```

   where
     - `<environment>` is the given environment (stage or prod)
     - `<app name>` is the name of the new service, as defined above

After completing these steps and getting all MRs/PRs reviewed and merged, the `psk-playbook-dispatcher` secret will be available in client application namespace(s).
