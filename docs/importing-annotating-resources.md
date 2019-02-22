# Importing / Annotating resources

From now onwards we are going to manage the ConfigMaps via the app-interface.

This guide is intended for those ConfigMaps that already exist and that need to be migrated to be under the control of app-interface.

During this importing process, these resources will receive new `metadata.annotations` fields that will link the resource to the app-interface.

Note that at the time of this document, the only resource type under the control of app-interface is `ConfigMap`, but this guide can serve as a generic process to import any kind of resource, by simply `s/ConfigMap/OtherResourceType/` in the examples below.

## Process

Declare all the resources in app-interface. This is added in the `/openshift/namespace-1.yml` files.

Validate the schemas by running `qontract-bundler` and then `qontract-validator`.

Start the `qontract-server` pointing to the bundle created by `qontract-bundler`:

```sh
# in the qontract-server directory
LOAD_METHOD=fs DATAFILES_FILE=/path/to/bundle/data.json yarn server
```

To run the `openshift-resources` integration, we need to first download the config file:

```sh
vault read -field=data_base64 app-sre/ci-int/qontract-reconcile-toml | base64 -d > config.toml
```

And then replace the `[graphql]` section with in the `config.toml` created above:

```toml
[graphql]
server = "http://localhost:4000/graphql"
```

Note that there is no `token` field.

Now we run the `openshift-resources` integration:

```sh
$ qontract-reconcile --config config.toml --dry-run openshift-resources
INFO:Skipping resource 'ConfigMap/app-interface' in 'app-sre/app-interface-production'. Present w/o annotations.
INFO:Skipping resource 'ConfigMap/vault' in 'app-sre/vault-stage'. Present w/o annotations.
INFO:Skipping resource 'ConfigMap/cincinnati' in 'app-sre/cincinnati-staging'. Present w/o annotations.
INFO:Skipping resource 'ConfigMap/app-interface' in 'app-sre/app-interface-staging'. Present w/o annotations.
INFO:Skipping resource 'ConfigMap/cincinnati' in 'app-sre/cincinnati-production'. Present w/o annotations.
```

We want to migrate (annotate) all the resources that were skipped because they were `Present w/o annotations`.

First step is to back up all the resources:

```sh
for n in app-interface-production vault-stage cincinnati-staging app-interface-staging cincinnati-production vault-prod; do
    oc get -n $n ConfigMap -o json > $n.configmaps.json
done
```

Note that the list of namespaces can be inferred from the output of the `openshift-resources` integration.

Now, we can import by simply executing the following **for each resource we want to import**.

```sh
qontract-reconcile --config config.toml [--dry-run] openshift-resources-annotate CLUSTER NAMESPACE RESOURCE_TYPE NAME
```

The recommendation is to run the command first with `--dry-run`. If the output is `INFO:annotated`, then it's safe to run it normally.

For example:

```sh
# check with dry-run
qontract-reconcile --config config.toml --dry-run openshift-resources-annotate app-sre app-interface-staging ConfigMap app-interface
qontract-reconcile --config config.toml --dry-run openshift-resources-annotate app-sre cincinnati-staging ConfigMap cincinnati
qontract-reconcile --config config.toml --dry-run openshift-resources-annotate app-sre vault-stage ConfigMap vault

# if they all display `INFO:annotated` then we can actually patch them.
qontract-reconcile --config config.toml openshift-resources-annotate app-sre app-interface-staging ConfigMap app-interface
qontract-reconcile --config config.toml openshift-resources-annotate app-sre cincinnati-staging ConfigMap cincinnati
qontract-reconcile --config config.toml openshift-resources-annotate app-sre vault-stage ConfigMap vault
```

After inspecting the ConfigMaps and ensuring this is not affecting staging, we can move ahead and patch production in the same way.

## Troubleshooting

- The ServiceAccount that performs this operation is defined in vault, and referenced by the `automationToken` field in the relevant `/openshift/cluster-1.yml` file. It may happen that this SA doesn't have enough privileges to perform the operation. In this case, the SA should be added to the namespace.
