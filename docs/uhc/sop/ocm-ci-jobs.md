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

### hive-frontend, aws-account-operator serviceAccounts and gcp-project-operator tokens

If the `hive-frontend` or `aws-account-operator` SAs are invalidated, they will be cycled automatically for the prod instance, but it must be addressed manually for the hive-int environment otherwise OCM will not be able to communicate with hive.

- Step 1. [AppSRE team] Copy the secret from `integration-output` to a path that the OCM team has access to:

```
AWS_TOKEN=$(vault read -field token app-sre/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/uhc-integration/hive-integration-aws-account-operator-aws-account-operator-client)
HIVE_TOKEN=$(vault read -field token app-sre/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/uhc-integration/hive-integration-hive-hive-frontend)
GCP_TOKEN=$(vault read -field token app-sre/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/uhc-integration/hive-integration-gcp-project-operator-gcp-project-operator-client)
vault write sd-uhc/sandbox-tokens aws-account-operator-client-token=$AWS_TOKEN hive-frontend-token=$HIVE_TOKEN gcp-project-operator-token=$GCP_TOKEN
```

- Step 2. [OCM team] Manually update the `config` (base64 encoded) to include the newly generated tokens that are available now in https://vault.devshift.net/ui/vault/secrets/sd-uhc/show/sandbox-tokens

- Step 3. [OCM team] Manually update the `hive_config` (base64 encoded) to include the newly generated tokens that are available now in https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre-stage/uhc-integration/clusters-cleaner
