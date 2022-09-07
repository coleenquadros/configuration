## Local Execution
If a given scenario requires local execution to reconcile Vault resources, the following command can be executed:

```
docker run --rm -t \
    -v <PATH_TO_FILE_WITH_GRAPHQL_QUERY>:/query.graphql \
    -e GRAPHQL_QUERY_FILE=/query.graphql \
    -e GRAPHQL_SERVER=<GRAPHQL_SERVER_URL> \
    -e GRAPHQL_USERNAME=<GRAPHQL_USERNAME> \
    -e GRAPHQL_PASSWORD=<GRAPHQL_PASSWORD> \
    -e VAULT_ADDR=<VAULT_INSTANCE_URL> \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=<APPROLE_ROLE_ID> \
    -e VAULT_SECRET_ID=<APPROLE_SECRET_ID> \
    quay.io/app-sre/vault-manager:latest -dry-run
```

* Note the presence of `dry-run` flag. Once dry-run output is verified, run the command again without `dry-run` to perform real reconciliation
* For reconciliation of vault.devshift.net, utilize [vault-manager-creds](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/vault-manager-creds) for role id and secret id

