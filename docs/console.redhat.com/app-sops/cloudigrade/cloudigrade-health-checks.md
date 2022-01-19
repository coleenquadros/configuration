# cloudigrade health checks

## Automatic

cloudigrade uses standard Kubernetes/OpenShift liveness and readiness probes (`livenessProbe` and `readinessProbe`) to ensure general availability of the service running in a pod. If the probes fail, the pod should automatically stop serving and be restarted or replaced. See the deployment config for details.

## Manual

If you want to check *manually* that cloudigrade is running, make HTTP requests via the public API (see [How do I reach these APIs](https://github.com/cloudigrade/cloudigrade/wiki/How-do-I-reach-these-APIs) for instructions with examples) or connect directly to a `cloudigrade-api` pod terminal in the `cloudigrade-stage` or `cloudigrade-prod` namespace as appropriate and try:

- `curl -v 127.0.0.1:8000/internal/healthz/`
    - This route should always respond with `200 OK` and a HTML document to indicate that the service is running and is able to communicate with the backing database.
    - The readiness probe requests this route to verify that the service is running.
- `curl -v 127.0.0.1:8000/api/cloudigrade/v2/azure-offer-template/`
    - This route should always respond with `200 OK` and a JSON document.
- `curl -v -H "X-RH-IDENTITY:eyJpZGVudGl0eSI6eyJhY2NvdW50X251bWJlciI6IjEyMyIsInVzZXIiOnsiaXNfb3JnX2FkbWluIjp0cnVlfX19Cg==" 127.0.0.1:8000/api/cloudigrade/v2/sysconfig/`
    - `X-RH-IDENTITY` contains base64-encoded JSON. See [How do I reach these APIs](https://github.com/cloudigrade/cloudigrade/wiki/How-do-I-reach-these-APIs) and [REST API Examples](https://github.com/cloudigrade/cloudigrade/blob/master/docs/rest-api-examples.rst) for further details.
    - If `X-RH-IDENTITY` is valid, this route should respond with `200 OK` and a JSON document.
    - If `X-RH-IDENTITY` is not valid, this route should respond with `401 Unauthorized` or `403 Forbidden` and an appropriate error message.


## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
