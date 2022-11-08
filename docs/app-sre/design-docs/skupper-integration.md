<font size="100">Skupper Integration</font>

---
Table of contents:

[toc]


## Author/date
Christian Assing - November 2022

## Tracking JIRA
https://issues.redhat.com/browse/APPSRE-6515

## Problem Statement
Creating a skupper network between namespaces on different clusters and exposing services needs a profound knowledge of skupper, how it works, the configuration, and how to connect skupper site links.

## Goal

Tenants should be able to specify skupper networks between namespaces on different clusters in app-interface similar to network policies. The integration must automate the creation, deletion, and upgrade of those skupper networks.

## Non-objectives

The integration won't handle exposing services on a skupper network. The tenants must use [the official skupper annotations](https://github.com/skupperproject/skupper/blob/f115df6db776f7124d6f909615394bc219c46f78/api/types/types.go#L138) on their deployments, services, and stateful sets.

## Proposal


Introduce `/dependencies/skupper-1.yml` schema:

```yaml
---
$schema: /dependencies/skupper-1.yml

identifier: <unique identifier>
config:
  cluster-local: <Set up skupper to only accept connections from within the local cluster. (true/false) default=false>
  console: <Enable skupper console. (true/false) default=true>
  console-authentication: <Authentication method. ('openshift',) default=openshift>
  console-ingress: <Determines if/how console is exposed outside cluster. (route/loadbalancer/none) default=route>
  controller-cpu-limit: <CPU limit for service-controller pods. default=500m>
  controller-cpu: <CPU request for service-controller pods. default=500m>
  controller-memory-limit: <Memory limit for controller pods. default=128Mi>
  controller-memory: <Memory request for controller pods. default=128Mi>
  controller-pod-antiaffinity: <Pod antiaffinity label matches to control placement of controller pods. default='skupper.io/component=controller'>
  controller-service-annotations: <Annotations to add to skupper controller service. default=unset>
  edge: <Set up an edge skupper site. (true/false) default=true for internal clusters>
  ingress: <(route/loadbalancer/ingress/none) Setup Skupper ingress specific type. default=route>
  name: <A name for the site. default={{ resource.namespace.cluster.name }}-{{ identifier }}>
  router-console: <Set up a Dispatch Router console (not recommended). (true/false) default=false>
  router-cpu-limit: <CPU limit for router pods. default=500m>
  router-cpu: <CPU request for router pods. default=500m>
  router-logging: <Logging settings for router (e.g. trace,debug,info,notice,warning,error). default=error>
  router-memory-limit: <Memory limit for router pods. default=156Mi>
  router-memory: <Memory request for router pods. default=156Mi>
  router-pod-antiaffinity: <Pod antiaffinity label matches to control placement of router pods. defaukt='skupper.io/component=router'>
  routers: <Number of router replicas to start. default=3>
  service-controller: <Run the service controller. (true/false) default=true>
  service-sync: <Determine if the service controller participates in service synchronization. (true/false) default=true>
  skupper-site-controller: <Skupper image and version>
```

Important configurations to highlight:

* `edge: true` for internal clusters behind the VPN
* `console-ingress: route` & `ingress: route` because a load-balancer IP isn't always available
* `skupper-site-controller` a required attribute and defines the skupper software version, e.g., `skupper-site-controller: quay.io/skupper/site-controller:1.1.1`

and enhance `/openshift/namespace-1.yml` with a `skupper` section:

```yaml
$schema: /openshift/namespace-1.yml
...
skupper:
  $ref: <path to /dependencies/skupper-1.yml file>
  delete: <deletion flag>
  # override/adapt default skupper configs (from /dependencies/skupper-1.yml) for this namespace, e.g. limits, replicas
  config:
    cluster-local: See /dependencies/skupper-1.yml
    console: See /dependencies/skupper-1.yml
    console-ingress: See /dependencies/skupper-1.yml
    controller-cpu-limit: See /dependencies/skupper-1.yml
    controller-cpu: See /dependencies/skupper-1.yml
    controller-memory-limit: See /dependencies/skupper-1.yml
    controller-memory: See /dependencies/skupper-1.yml
    controller-service-annotations: See /dependencies/skupper-1.yml
    edge: See /dependencies/skupper-1.yml
    ingress: See /dependencies/skupper-1.yml
    name: See /dependencies/skupper-1.yml
    router-console: See /dependencies/skupper-1.yml
    router-cpu-limit: See /dependencies/skupper-1.yml
    router-cpu: See /dependencies/skupper-1.yml
    router-logging: See /dependencies/skupper-1.yml
    router-memory-limit: See /dependencies/skupper-1.yml
    router-memory: See /dependencies/skupper-1.yml
    routers: See /dependencies/skupper-1.yml
    service-controller: See /dependencies/skupper-1.yml
    service-sync: See /dependencies/skupper-1.yml
```
Given that, the integration will:

* Create a `skupper-site` config map with config settings from the `config` sections.
* Deploy a *site-controller* (with a specific skupper version) into all related namespaces in all associated clusters.
* Create *connection-tokens* and spawn skupper connections by considering that an internal cluster doesn't allow incoming connections.

For `delete: true`, the integration will delete the `skupper-site` config map, *site-controller*, *connection-tokens* secrets, and skupper services.

## Details

### Definitions

* A **public** cluster is publicly accessible
* An **internal** cluster is not publicly accessible and is behind the VPN
* An **edge** cluster (site-config `edge: true`) doesn't allow incoming skupper site connections.
* A **non-edge** cluster (site-config `edge: false`) allows incoming skupper site connections.

### Site Controller Deployment

The *site-controller* is a Kubernetes deployment similar to the one used in the [POC](https://gitlab.cee.redhat.com/service/app-interface/-/blob/4751dee2c4ed02e5a3fbde4617074c508bf74e6c/resources/skupper-cassing/skupper/site-controller.yml).

### Site connections

Skupper site connections have several constraints to be fulfilled:

* Public clusters cannot access internal clusters behind the VPN
* Internal clusters may access other internal clusters
* A connection token from the cluster you want to connect to needs to be available and valid
* There is no need to bidirectional connect sites. Cluster A connects to B, but B doesn't need to connect to A.

Apply these rules to create the connections:

| Public         | Internal       | Edge           | Non-Edge       | Rule                                                                            |
| -------------- | -------------- | -------------- | -------------- | ------------------------------------------------------------------------------- |
| :red_circle:   | :green_circle: | :green_circle: | :red_circle:   | Connect to all[^all] other **non-edge** clusters (lexicographical order)        |
| :red_circle:   | :green_circle: | :red_circle:   | :green_circle: | Connect to all[^all] other **non-edge** clusters (lexicographical order)        |
| :green_circle: | :red_circle:   | :red_circle:   | :green_circle: | Connect to all[^all] other **public non-edge** clusters (lexicographical order) |
| :green_circle: | :red_circle:   | :green_circle: | :red_circle:   | Connect to all[^all] other **public non-edge** clusters (lexicographical order) |

[^all]: All or a configurable (app-interface settings) max number


## Milestones

* [ ] AppSRE team approval
* [ ] Implementation of the integration
* [ ] Use for grafana -> prometheus connections
* [ ] Cleanup [skupper-example](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/skupper-cassing) from app-interface

## Limitations and Open Topics

* [custom annotations on skupper deployments](https://github.com/skupperproject/skupper/issues/930)
* [skupper-router restart leads to network interruption](https://github.com/skupperproject/skupper/issues/940)

## Links

* [Skupper design doc](skupper.md)
