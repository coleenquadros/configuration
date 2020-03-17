# Debugging high memory usage

## The application is exceeding the resident memory alarm

- Check the [Grafana memory graph] to determine if multiple pods are using higher than normal memory usage or if it's only a single pod.
- Obtain a shell in the `quay-app` container of aforementioned pod to determine if there's a particular porcess leaking the memory. This can be done in the OpenShift Console or by executing `kubectl -n quay exec -ti $POD -c quay-app bash`.
- Use standard tools like `ps` to inspect processes to determine which processes are consuming the memory within the pod.
- File a JIRA ticket for the Quay development team with as much information as possible.
- Delete the pod with `kubectl -n quay delete pod $POD` or restart entire deployment by executing `kubectl -n quay rollout restart deployment/quay-app`. You can monitor a rollout by executing `kubectl -n quay rollout status deployment/quay-app`.

[Grafana memory graph]: https://grafana.app-sre.devshift.net/d/_BkydJaWz/quay-io-runtime?orgId=1&fullscreen&panelId=4
