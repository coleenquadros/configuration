# Preparing for Private Repositories

Docker's ToS prevents us from mirroring public images in Docker Hub to *public* registries in quay.io.

If we arbitrarily make a public quay.io repository private, we may break the service as the ServiceAccount may not have the necessary pull secrets to fetch the now private image.

As of 2021-02-02 we have a spreadsheet with the list of pods that are using images in a public quay.io repo that has been mirrored from Docker Hub: [Pods with images from Docker.io](https://docs.google.com/spreadsheets/d/1Z7BfIyGFMZXBJCVk2i-Zt8l15-dKjFjmfSMbEaqkg0o/edit#gid=2077173594).

## Ensure the namespace has the quay.io pull secret

Ensure that the quay.io pull secret has to be added to the namespace as follows:

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

You will note that [/services/common/serviceaccount.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/95eb17194b2bd801b5fc77a1b041f0b42d2344b0/resources/services/common/serviceaccount.yaml#L6) includes the `quay.io` pull secret.

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

The definition of the ServiceAccount will be found in the `namespace` file, reference in either the `openshiftResources` parameter or in the `sharedResources` one.

## Patch upstream to use the new serviceAccount

Find the upstream repository (you can locate it following the `saas_file`), and patch it in order to include the previously defined named `ServiceAccount` as such:

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

After you commit this, it will trigger a deployment to staging. If it works successfully, you can promote to prod.
