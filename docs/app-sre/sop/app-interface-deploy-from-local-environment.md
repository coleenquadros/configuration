# App-interface deloy from local environment

Since we are deploying app-interface (specifically qontract-server) from a saas file, it means that we need app-interface (specifically, again, qontract-server) to be up.

This SOP should be used in case qontract-server (https://app-interface.devshift.net) is down and we need to re-deploy it.

## Process

1. Clone app-interface, CD into it and run a server:
```shell
git clone https://gitlab.cee.redhat.com/service/app-interface.git
cd app-interface
make server
```

1. Create a `config` directory and place a `config.toml` in it with the contents of the `local_data` key from the [qontract-reconcile-toml Vault secret](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml).

1. Run the qontract-reconcile openshift-saas-deploy integration:
```shell
docker run --rm \
    --network host \
    -v $PWD/config:/config:z \
    quay.io/app-sre/qontract-reconcile:latest \
    qontract-reconcile --config /config/config.toml \
    openshift-saas-deploy \
    --saas-file-name saas-app-interface \
    --env-name app-interface-production
```

App-interface is now deployed.
