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
    * [[schema](/schemas/openshift/cluster-1.yml#L103-125)]
    * [[example](/data/openshift/insights/cluster.yml#L20-27)]

- AWS account:
    * disable `integrations`
    * [[schema](/schemas/aws/account-1.yml#L29-38)]
    * [[example](/data/aws/osio-dev/account.yml#L16-18)]
