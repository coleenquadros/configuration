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

If the `hive-frontend`, `aws-account-operator` or `gcp-project-operator` SAs are invalidated, they need to recycled manually for the above listed jobs to keep functioning, otherwise they will not be able to communicate with hive.

Follow these instructions:

- Step 1. [OCM team] Manually update the `config` (base64 encoded) key of the [sandbox](https://vault.devshift.net/ui/vault/secrets/sd-uhc/show/sandbox) secret to include the most recent tokens that are available now in:
    * `hive-frontend`: https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/uhc-integration/hivei01ue1-hive-hive-frontend
    * `aws-account-operator`: https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/uhc-integration/hivei01ue1-aws-account-operator-aws-account-operator-client
    * `gcp-project-operator`: https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/uhc-integration/hivei01ue1-gcp-project-operator-gcp-project-operator-client

> Note: Access to these secrets in Vault is defined [here](data/services/vault.devshift.net/config/policies/sd-uhc-policy.yml) and they can be viewed by anyone with the [vault-access](data/teams/ocm/roles/vault-access.yml) role associated to their user. Find a list of these users in [Visual app-interface](https://visual-app-interface.devshift.net/roles#/teams/ocm/roles/vault-access.yml).
