# Running qontract-reconcile manually (not for development)

To run integrations manually, perform the following steps:

Prerequisites: 
- `vault` : CLI for Vault. Can be obtained from the `vault` package on Fedora and CentOS
- `pip` : Install the `python-pip` package. Make sure its the Python2 Version
- `virtualenv` : Install using pip, `pip install virtualenv`
- A Github personal access token. Obtained from: https://github.com/settings/tokens

```
# clone the qontract-reconcile repo
git clone https://github.com/app-sre/qontract-reconcile.git && cd qontract-reconcile

# start a python virtual environment
python3 -m venv venv

# activate virtual environment and install
source venv/bin/activate
python3 setup.py install

# prepare vault environment variables
export VAULT_ADDR=https://vault.devshift.net
vault login -method=oidc

# get the config file from vault using the CLI:
vault kv get -field=data_base64 app-sre/ci-int/qontract-reconcile-toml | base64 -d > config.debug.toml

You can also get the file directly from: https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml

# run the integration with --dry-run (in this example - terraform-resources)
qontract-reconcile --config config.debug.toml --dry-run terraform-resources

# if a manual reconciliation is required - run the integration again without --dry-run
qontract-reconcile --config config.debug.toml terraform-resources
```

# Running vault-manager manually (not for development)

Prerequisites: 
- `vault` : CLI for Vault. Can be obtained from the `vault` package on Fedora and CentOS
- A Github personal access token. Obtained from: https://github.com/settings/tokens

To run the vault-manager integration manually, perform the following steps:
```
# prepare vault environment variables
export VAULT_ADDR=https://vault.devshift.net
export DISABLE_IDENTITY=true
vault login -method=oidc

gql_data=$(vault kv get -format=json app-sre/creds/app-interface/production/basic-auth)
export GRAPHQL_SERVER="$(echo $gql_data | jq -r .data.base_url)/graphql"
export GRAPHQL_USERNAME="$(echo $gql_data | jq -r .data.username)"
export GRAPHQL_PASSWORD="$(echo $gql_data | jq -r .data.password)"

vm_data=$(vault kv get -format=json app-sre/ci-int/vault-manager-creds)
export VAULT_AUTHTYPE="$(echo $vm_data | jq -r .data.auth_type)"
export VAULT_MANAGER_ROLE_ID="$(echo $vm_data | jq -r .data.role_id)"
export VAULT_MANAGER_SECRET_ID="$(echo $vm_data | jq -r .data.secret_id)"

export VAULT_RECONCILE_IMAGE=quay.io/app-sre/vault-manager
export VAULT_RECONCILE_IMAGE_TAG=<get used image tag from app-interface/.env file>

docker run --rm -t \
    -e GRAPHQL_SERVER=${GRAPHQL_SERVER} \
    -e GRAPHQL_USERNAME=${GRAPHQL_USERNAME} \
    -e GRAPHQL_PASSWORD=${GRAPHQL_PASSWORD} \
    -e VAULT_ADDR={VAULT_ADDR} \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=${VAULT_MANAGER_ROLE_ID} \
    -e VAULT_SECRET_ID=${VAULT_MANAGER_SECRET_ID} \
    ${VAULT_RECONCILE_IMAGE}:${VAULT_RECONCILE_IMAGE_TAG} -dry-run
```
Note: if a manual reconciliation is required - run the integration again without -dry-run
