# OCM CI Jobs

OCM CI runs against the sandbox environment in `hive-int`.

## List of jobs

This is the list of related jobs (those that consume the secret [sd-uhc/sandbox](https://vault.devshift.net/ui/vault/secrets/sd-uhc/show/sandbox)).

- `service-api-tests-ocm-build-master`
- `service-api-tests-ocm-pr-check`
- `service-ocm-resources-ocm-build-master-timed-production`
- `service-ocm-resources-ocm-pr-check`
- `service-ocm-resources-ocm-build-master-timed-stage`
- `service-ocm-service-log-ocm-pr-check`
- `service-ocm-resources-ocm-build-master`
- `service-uhc-account-manager-ocm-pr-check`
- `service-uhc-clusters-service-ocm-pr-check`

This list has been obtained by running:

```
$ qontract-reconcile --config config.prod.toml --dry-run jenkins-job-builder --io-dir jjb --no-compare
$ grep -RF '<path>sd-uhc/sandbox</path>' jjb
```

## Invalidated Tokens

### Offline user session not found (clusters-service)

Clusters-service uses the `config` (base64 encoded) field in [sd-uhc/sandbox](https://vault.devshift.net/ui/vault/secrets/sd-uhc/show/sandbox) to run the tests. It includes a parameter named `self.token` which is a token obtained from resource: [ocm/production.yml](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/dependencies/ocm/production.yml).

If this token is invalidated, it will be automatically recycled in the for the production clusters-service instance, but that won't happen automatically for hive-int (OCM CI). This will trigger an error like this one:

```
2020-04-28T10:10:19Z [INFO] [log/logging_transport.go:29] [<REDACTED_ID>]- Sending POST /auth/realms/redhat-external/protocol/openid-connect/token
2020-04-28T10:10:19Z [INFO] [log/logging_transport.go:48] [<REDACTED_ID>]- Got back http 400
2020-04-28T10:10:19Z [INFO] [apiserver/handler_helpers.go:191] [<REDACTED_ID>]- can't get access token: invalid_grant: Offline user session not found
```

In order to fix this: TODO

### hive-frontend and aws-account-operator serviceAccounts

If the `hive-frontend` or `aws-account-operator` SAs are invalidated, they will be cycled automatically for the prod instance, but it must be addressed manually for the hive-int environment otherwise OCM will not be able to communicate with hive.

- Step 1. [AppSRE team] Copy the secret from `integration-output` to a path that the OCM team has access to:

```
AWS_TOKEN=$(vault read -field token app-sre/integrations-output/openshift-serviceaccount-tokens/hive-integration/uhc-integration/hive-integration-aws-account-operator-aws-account-operator-client)
HIVE_TOKEN=$(vault read -field token app-sre/integrations-output/openshift-serviceaccount-tokens/hive-integration/uhc-integration/hive-integration-hive-hive-frontend)
vault write sd-uhc/sandbox-tokens aws-account-operator-client-token=$AWS_TOKEN hive-frontend-token=$HIVE_TOKEN
```

- Step 2. [OCM team] Manually update the `config` (base64 encoded) to include the newly generated tokens that are available now in https://vault.devshift.net/ui/vault/secrets/sd-uhc/show/sandbox-tokens
