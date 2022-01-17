# cloudigrade health checks

## Automatic

cloudigrade uses standard Kubernetes/OpenShift liveness and readiness probes (`livenessProbe` and `readinessProbe`) to ensure general availability of the service running in a pod. If the probes fail, the pod should automatically stop serving and be restarted or replaced. See the deployment config for details.

## Manual

If you want to check *manually* that cloudigrade is running, consider trying one of the following:

- HTTP GET `/internal/healthz/`
    - This route is internal and requires no special authentication.
    - This route should always respond with `200 OK` and a HTML document to indicate that the service is running and is able to communicate with the backing database.
    - The readiness probe requests this route to verify that the service is running.
- HTTP GET `/api/cloudigrade/v2/azure-offer-template/`
    - This route is public and requires no special authentication.
    - This route should always respond with `200 OK` and a JSON document.
- HTTP GET `/api/cloudigrade/v2/sysconfig/`
    - This route is public but requires HTTP Basic authentication with credentials for any Red Hat customer who has "org admin" set.
    - If authenticated correctly, this route should respond with `200 OK` and a JSON document.
    - If not authenticated, this route should respond with `401 Unauthorized` or `403 Forbidden` and an appropriate error message.

See [How do I reach these APIs](https://github.com/cloudigrade/cloudigrade/wiki/How-do-I-reach-these-APIs) for further instructions and examples for making HTTP requests to cloudigrade.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
