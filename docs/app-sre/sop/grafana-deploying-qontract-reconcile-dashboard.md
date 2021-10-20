## Deploying The Qontract Reconcile Dashboard to New Service Saas File

- Make sure that the saas file that corresponds to the service can be updated by `pr-promote`

- Update the original project Github to include the `configmap.yaml` file.

- Add a `resourceTemplate` entry in the [service saas file](/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml) to deploy your dashboard.
  ```yaml
  - name: your-service-dashboards
    url: https://gitlab.cee.redhat.com/service-registry/your-service
    path: /dashboards
    provider: directory
    targets:
    - namespace:
        $ref: /services/observability/namespaces/app-sre-observability-stage.yml
      ref: master
  ```
- Run `qr-promote`

- Create a merge request to push up the changes.