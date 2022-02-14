# Disable qontract-reconcile integrations for specific resources

To disable an integration from running on specific resources, the following section should be added to the resource file:

```yaml
disable:
  integrations:
  - openshift-users
```

To disable an E2E test from running on specific resources, the following section should be added to the resource file:

```yaml
disable:
  e2eTests:
  - create-namespace
```

Available options:

- Cluster:
    * disable `integrations` and/or `e2e-tests`
    * [schema](https://github.com/app-sre/qontract-schemas/blob/ad05411b16709ddf94f574cd3356319f3fd7298b/schemas/openshift/cluster-1.yml#L450-L481)]
    * [example](/data/openshift/insights/cluster.yml#L20-27)]

- AWS account:
    * disable `integrations`
    * [schema](https://github.com/app-sre/qontract-schemas/blob/7780755424781d8b88839d2c37e32ccb45fc52da/schemas/aws/account-1.yml#L52-L62)]
    * [example](/data/aws/osio-dev/account.yml#L16-18)]
