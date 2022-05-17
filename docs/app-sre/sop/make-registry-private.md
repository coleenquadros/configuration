# Preparing for Private Repositories

Docker's [ToS](https://www.docker.com/legal/docker-terms-service/) prevents us from mirroring public images in Docker Hub to *public* registries in quay.io (see item 2.4 in the linked docker document).

If we arbitrarily make a public quay.io repository private, we may break the service as the ServiceAccount may not have the necessary pull secrets to fetch the now private image.

As of 2021-02-02 we have a spreadsheet with the list of pods that are using images in a public quay.io repo that has been mirrored from Docker Hub: [Pods with images from Docker.io](https://docs.google.com/spreadsheets/d/1Z7BfIyGFMZXBJCVk2i-Zt8l15-dKjFjmfSMbEaqkg0o/edit#gid=2077173594).

## Ensure the namespace has the quay.io pull secret

Ensure that the quay.io pull secret exists in the namespace where your pods are running as follows.

The preferred approach is to use a shared resource:

```yaml
sharedResources:
- $ref: /services/app-sre/shared-resources/quayio-pull-secret.yml
```

but it may already exist directly as an openshift resource:

```yaml
---
$schema: /openshift/namespace-1.yml
...
openshiftResources:
- provider: vault-secret
  path: app-interface/global/quay/app-sre/quay.io
  version: 2
  type: kubernetes.io/dockercfg
  ...
```

## Add a new ServiceAccount

**NOTE**: Ignore this step if you already have a serviceAccount in the namespace that is not `default` which is suitable to run the workload.

The `ServiceAccount` can be added like this:

```yaml
---
$schema: /openshift/namespace-1.yml
...
managedResourceTypes:
  ...
  - ServiceAccount
openshiftResources:
  ...
  - provider: resource-template
    path: /services/common/serviceaccount.yaml
    variables:
        name: <name>
```

Note that [/services/common/serviceaccount.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/95eb17194b2bd801b5fc77a1b041f0b42d2344b0/resources/services/common/serviceaccount.yaml#L6) includes the `quay.io` pull secret.

## Adding quay.io pull secret to the ServiceAccount

**NOTE**: Ignore this step if you added the serviceAccount in the previous step.

We need to make sure that the serviceAccount that is being used by the deployment includes a `quay.io` pull secret.

In order to do so, simply verify (or patch) the list of image pull secrets of the service account:

```yaml
---
apiVersion: v1
kind: ServiceAccount
imagePullSecrets:
- name: default-dockercfg-8bg88
...
```

The ServiceAccount may have been defined in two places:

1. In App-Interface, in the `namespace` file, referenced in the `openshiftResources` parameter or in the `sharedResources` one.
1. In the upstream repo, referenced by `saas_file`.

Either way, you must make sure that the SA contains the `quay.io` imagePullSecret.

## Patch upstream to use the new serviceAccount

Find the upstream repository where the openshift manifests for your application are located (you can locate it following the `saas_file`), and patch them in order to include the service account from the previous steps in the appropriate openshift object:

```yaml
---
apiVersion: ...
kind: Deployment | DeploymentConfig | StatefulSet
...
spec:
  ...
  template:
    ...
    spec:
      serviceAccountName: <name>
...
```

If the pods need to read config from a Secret or a ConfigMap or any other special action, you may need to add capabilities via a Role, e.g. https://gitlab.cee.redhat.com/service/app-sre-observability/-/blob/5a9eda36cb0846c697d8afa7d4b75d7f534cce2b/openshift/cloudwatch-exporter.template.yaml#L12-35


## Add authentication in saas file

Find saas file for your application, add the authentication for get private images:

```yaml
authentication:
  image:
    path: app-sre/quay/app-sre-pull
    field: all
```

After you commit this, it will trigger a deployment to staging. If it works successfully, you can promote to prod.
