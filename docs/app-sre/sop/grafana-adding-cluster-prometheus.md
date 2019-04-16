## Adding a new cluster-prometheus instance to the app-sre Grafana

Adding a cluster-prometheus instance to our grafana setup allows us to have a central place to visualize cluster metrics for all app-sre managed clusters

- Log in to the cluster whose Prometheus needs to be added

- Get the htpasswd string that Grafana can use to talk to the cluster's Prometheus

`oc get secrets grafana-datasources -n openshift-monitoring -o yaml`

- Next, we need to add this to the app-sre Grafana setup via datasource provisioning. 

    - Edit the grafana-datasources secret in vault, which is currently in the app-sre-prometheus namespace in the app-sre cluster. [Link](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-prometheus/grafana/grafana-datasources)

- Once the secret is updated, we need to bump the secret version in app-interface for the corresponding namespace. For example, the grafana-datasources secret is referenced here [Link](https://gitlab.cee.redhat.com/service/app-interface/blob/49771fdb03749dfeed871d05cb447438232bfb50/data/services/observability/namespaces/app-sre-prometheus.yml#L56-58)

- Once the PR to app-interface is merged, check for the availability of the new datasource in Grafana
