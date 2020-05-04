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
virtualenv venv

# activate virtual environment and install
source venv/bin/activate
python setup.py install

# prepare vault environment variables
export VAULT_ADDR=https://vault.devshift.net
export TOKEN=$(cat ~/path/to/github/token)
vault login -method=github token=$TOKEN

# get the config file from vault using the CLI:
vault kv get -field=data_base64 app-sre/creds/qontract-reconcile-toml | base64 -d > config.debug.toml

You can also get the file directly from: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/qontract-reconcile-toml

# run the integration with --dry-run (in this example - terraform-resources)
qontract-reconcile --config config.debug.toml --dry-run terraform-resources

# if a manual reconciliation is required - run the integration again without --dry-run
qontract-reconcile --config config.debug.toml terraform-resources
```


**Note: If you're using python3 by default, you must create a virtualenv specifying
the use of the python2 executable path. The command to create it would then be:**
 
`virtualenv --python=/usr/bin/python2 venv`
