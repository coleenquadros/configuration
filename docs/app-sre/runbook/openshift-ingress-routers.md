# OpenShift Ingress Routers

[TOC]

## Overview

The OpenShift ingress routers provide a method for exposing services externally (outside the cluster). The routers are managed by the [Ingress Operator](https://docs.openshift.com/container-platform/4.9/networking/ingress-operator.html) and services are exposed via [Routes](https://docs.openshift.com/container-platform/4.9/networking/routes/route-configuration.html).

## Architecture

The architecture of ingress routers is not well-documented in OSD docs at this time (as far as I can tell). Knowing the architecture can be useful when troubleshooting some issues, however.

![OSD Ingress Routers](img/osd-ingress-routers.png "OSD Ingress Router Architecture")

Very simply, the `Route` DNS points to an AWS Classic ELB, which load balances the traffic to the router pods. Knowledge of the Classic ELB can be important, however, because it provides another layer of metrics for investigation purposes. For instance, there are the `SurgeQueueLength` and `SpilloverCount` metrics ([see AWS docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-cloudwatch-metrics.html)), the latter being an indicator of clients seeing closed connections if the ingress router pods are overloaded.

More information about the `Service`, which is the ELB, can be found by running the following command on a cluster: `oc get svc -n openshift-ingress`

## Metrics and Dashboards

* [OpenShift Router Metrics (per cluster, per pod)](https://grafana.app-sre.devshift.net/d/kMh0vlEWk/openshift-router-metrics?orgId=1&refresh=5m)
  * This is an AppSRE dashboard highlighting some of the more important metrics exposed by router pods
* ELB metrics can be found in the OSD AWS account using the switch role link in [this document](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ocm-aws-infrastructure-access-switch-role-links.md)

## Troubleshooting

### Most/All applications on a cluster have high latency / increased errors

All routes on an OSD cluster share the same ingress router by default. So, if there are issues with that router, you may see increased latency/errors in not just tenant services, but also Prometheus, OCP console, and other `Routes`.

1. Check the [OpenShift Router Metrics dashboard](#metrics-and-dashboards) for any increase in the number of sessions, HTTP response codes, etc. If there are elevated requests/connections, try to find the route associated with this increase, and reach out to the tenant to see if this increase in traffic is expected.
2. The steps below will focus on determining if the infra nodes / ingress routers are overloaded. These steps can be relevant whether the increase in traffic at the routers is expected or not.
3. Login to the affected cluster with the login command from the OCP console
4. Get the infra node names that are running the ingress router pods:\
   ```oc get pods -n openshift-ingress -o=jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}'```
5. Check the infra node CPU usage by looking for the node names above in the output of the command below. If the infra nodes have very high CPU usage, this could be affecting the ingress routers.\
   ```oc adm top nodes```
6. Check the OCP console dashboards (`Observe -> Dashboards`), specifically the `Kubernetes / Compute Resources / Node (Pods)` graph for increased CPU usage related to the router namespace (`openshift-ingress`)
7. Check the `Kubernetes / Networking / Cluster` dashboard, in the `Errors` section for signs of changes in dropped packets, or retransmitted packets. This might be a contributing factor to router ingress issues.
8. If the investigation above indicates that the routers are failing to meet the incoming requests, and the infra nodes are overloaded, see the [SOPs](#sops) section for scaling the infra nodes. If we otherwise suspect issues with the infra nodes, then it might be necessary to escalate to SRE-P (may need a general SOP for this).


## SOPs

* [Scaling infra nodes](/docs/app-sre/sop/scaling-osd-infra-nodes.md)

## OSD-specific considerations

This section attempts to cover cases where OSD might deviate from typical OCP operations.

### Scaling Ingress Routers

Some important notes on scaling the ingress router in OSD:

1. Increasing the number of ingress router pods cannot be self-serviced. This means that the default of 2 pods is not easily changed and SRE-P usually doesn't make exceptions. It's possible that this could change in the future with [NE-361](https://issues.redhat.com/browse/NE-361).
2. The infra nodes can be vertically scaled (to the next EC2 instance size). See the [SOPs](#sops) section for more information.

The original discussion with SRE-P can be found in [Slack](https://coreos.slack.com/archives/CCX9DB894/p1640012063193800).

### Access Logging

Enabling access logging, like you can do in [OCP](https://docs.openshift.com/container-platform/4.9/networking/ingress-operator.html#nw-configure-ingress-access-logging_configuring-ingress), is not directly supported by SRE-P. While it can be done with cluster-admin, doing so **will result in the router pods being restarted, which can cause a momentary traffic disruption**.

**Note:** AppSRE has not enabled ingress router access logs on a production cluster in the past. Investigation is required to determine the additional resources that might be consumed by a busy router.

The original discussion with SRE-P can be found in [Slack](https://coreos.slack.com/archives/CCX9DB894/p1640029687217400).

## Known Issues

### Overloaded routers affect tenant services as well as other infrastructure

It is worth knowing that overloaded routers / infra nodes can lead to a situation where multiple tenant services and infrastructure components can become unreachable. In an incident that involved [OCM degradation](https://docs.google.com/document/d/1wxXTiXLK8v7JuwOnm7Jte5-jU50qAhEljFTsIexM6Ho/edit#), not only were OCM services impacted, but team members were also having issues reaching Prometheus and the OCP Console, because that traffic also passes through the default OpenShift ingress routers on the cluster.

This might lead to further discussions about architecture in the future. It isn't good when production services are impacted, but it's even worse when the team is trying to troubleshoot and OCP console/Prometheus access is also affected.
