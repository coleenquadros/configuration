# Rate limiting 

## Smoke test
Since rate-limiting is not exposed publicly, the fastest way to determine if it's running is to check if the [customized Prometheus metrics](https://github.com/Kuadrant/limitador/blob/main/limitador/src/prometheus_metrics.rs#L22) are coming in to the Grafana dashboard mentioned in app.yml.

To perform an end-to-end test from the service that supposed to be able to access rate-limiting service, you can do following:
1. Log into the cluster and the namespace where the upstream service is.
2. Run following commands
```
oc exec -it upstream-service-pod -- /bin/bash
bash-4.4$ curl -v limitador.app-sre-rate-limiting.svc:8080/status
```

Another way to health check the rate-limiting pods is:

1. Log into the cluster and rate-limiting's namespace.
2. Run following commands to port forward the service's traffic:
```
oc port-forward service/limitador 8080:8080
```
3. Access the rate-limiting's status page by running:
```
curl -v localhost:8080/status
```
 You should get a 200 in both cases if the service is running as expected. If further diagnose needed for each individual pod, replace the `service/limitador` with pod's name.

## Troubleshooting
### RateLimitingUnavailable
Since it is set to not to fail the request(`failure_mode_deny: false`) in [Envoy](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/http/ratelimit/v3/rate_limit.proto#envoy-v3-api-field-extensions-filters-http-ratelimit-v3-ratelimit-failure-mode-deny) if rate-limiting returns an error, there is no blocking when rate-limiting is unavailable. However, backend service can expect higher than normal amount of load so there is a higher chance of resource exhaustion.

1. logging into app-sre-prod-04 [Grafana](https://grafana.app-sre.devshift.net/d/k8s-compute-resources-cluster/kubernetes-compute-resources-cluster?var-datasource=app-sre-prod-04-prometheus)
2. Pull application logs by running this query:
```
fields @message, kubernetes.namespace_name, kubernetes.container_name
| filter kubernetes.namespace_name = "app-sre-rate-limiting" and kubernetes.container_name = "limitador"
```
3. Pull redis logs by running above query with `container_name = "redis"` instead.
4. Use [console](https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/k8s/ns/app-sre-rate-limiting/pods) to restart the pods if determined necessary.
5. Reach out to App SRE @app-sre-ic in #app-sre or #sd-app-sre-teamchat

### RatelimitingErrorRateHigh

Same troubleshooting steps as above.

### Useful links:
[Upstream repo](https://github.com/Kuadrant/limitador)
[App SRE implemented template repo](https://gitlab.cee.redhat.com/service/rate-limiting-templates/-/tree/master/0)
