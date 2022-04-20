# OSDv4 : openshift-customer-monitoring

## Context

The openshift-customer-monitoring namespace was born out of a cross team effort between app-sre and the platform SRE teams to facilitate migration of production workloads to OpenShift v4. OpenShift v4 (until v4.5) does not have a supported way of running a workload monitoring Prometheus, and thus we needed to create this stack to make sure we're runnign Prometheus Operator within the RBAC boundaries of OpenShift Dedicated

An interesting limitation here is that the Prometheus Operator can only be installed in the `openshift-customer-monitoring` namespace due to an OLM limitation that allows privilege escalation if you have an operator installed to a regular namespace. This is the reason we have a very tailored RBAC setup in this namespace.

## Deployment Structure

There's two namespaces involved in osdv4 workload monitoring

namespace: openshift-customer-monitoring
contains:

- Alertmanager
- Prometheus

namespace: app-sre-observability-production
contains:

- Grafana
- Exporters

Servicemonitors and PrometheusRules are created in the `openshift-customer-monitoring` namespace

## RBAC

Dedicated admins have a restricted set of permissions on the openshift-customer-monitoring namespace.

The most accurate permissions set can be found in the [OSD role configuration](https://github.com/aditya-konarde/managed-cluster-config/blob/master/deploy/osd-customer-monitoring/05-role.yaml)

### Some pitfalls

- Due to the limitations in RBAC, we can only have a single alertmanager cluster in the namespace, and the alertmanager CR must be named `instance`. We're also only allowed to manage the corresponding configuration secret called `alertmanager-instance` that the Prometheus operator expects
- As we as dedicated admins can't create/edit secrets other than the whitelist above, we cannot use openshift-acme in this namespace

## Other changes from v3

- In OSDv4, router metrics are ingested directly by the Cluster Prometheus, we use federation to get them into the workload Prometheus
- Instead of a central alertmanager cluster, we are moving towards a model where each cluster has its own alertmanager. The alerting configuration will be the same across all alertmanagers
