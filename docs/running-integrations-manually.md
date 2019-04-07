# Running qontract-reconcile manually (not for development)

To run integrations manually, perform the following steps:


```
# clone the qontract-reconcile repo
git clone https://github.com/app-sre/qontract-reconcile.git && cd qontract-reconcile
# start a python virtual environment
virtualenv venv
# activate virtual environment and install
source venv/bin/activate
python setup.py install
# prepare vault environment variables
export VAULT_ADDR=https://vault.devshift.net
export TOKEN=$(cat ~/path/to/github/token)
vault login -method=github token=$TOKEN
# get the config file from vault
vault kv get -field=data_base64 app-sre/ci-int/qontract-reconcile-toml | base64 -d > config.debug.toml
# run the integration with --dry-run (in this example - terraform-resources)
qontract-reconcile --config config.debug.toml --dry-run terraform-resources
# if a manual reconciliation is required - run the integration again without --dry-run
qontract-reconcile --config config.debug.toml terraform-resources
```
