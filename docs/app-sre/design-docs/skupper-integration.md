<font size="100">Skupper Integration</font>

---
Table of contents:

[toc]


## Author/date
Christian Assing - November 2022

## Tracking JIRA
https://issues.redhat.com/browse/APPSRE-6515

## Problem Statement
Creating a Skupper network between namespaces on different clusters and exposing services needs a profound knowledge of Skupper, how it works, the configuration, and how to connect Skupper site links.

## Goal

Tenants should be able to specify Skupper networks between namespaces on different clusters in app-interface similar to network policies. The integration must automate the creation, deletion, and upgrade of those Skupper networks.

## Non-objectives

The integration won't handle exposing services on a Skupper network. The tenants must use [the official Skupper annotations](https://github.com/skupperproject/skupper/blob/f115df6db776f7124d6f909615394bc219c46f78/api/types/types.go#L138) on their deployments, services, and stateful sets.

## Proposal


Introduce `/dependencies/skupper-1.yml` schema:

```yaml
---
$schema: /dependencies/skupper-1.yml

identifier: <unique identifier>
config:
  cluster-local: <Set up Skupper to only accept connections from within the local cluster. (true/false) default=false>
  console: <Enable Skupper console. (true/false) default=true>
  console-authentication: <Authentication method. ('openshift',) default=openshift>
  console-ingress: <Determines if/how console is exposed outside cluster. (route/loadbalancer/none) default=route>
  controller-cpu-limit: <CPU limit for service-controller pods. default=500m>
  controller-cpu: <CPU request for service-controller pods. default=500m>
  controller-memory-limit: <Memory limit for controller pods. default=128Mi>
  controller-memory: <Memory request for controller pods. default=128Mi>
  controller-pod-antiaffinity: <Pod antiaffinity label matches to control placement of controller pods. default='skupper.io/component=controller'>
  controller-service-annotations: <Annotations to add to Skupper controller service. default=unset>
  edge: <Set up an edge Skupper site. (true/false) default=true for internal clusters>
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
* `skupper-site-controller` a required attribute and defines the Skupper software version, e.g., `skupper-site-controller: quay.io/skupper/site-controller:1.1.1`

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
* Deploy a *site-controller* (with a specific Skupper version) into all related namespaces in all associated clusters.
* Create *connection-tokens* and spawn Skupper connections by considering that an internal cluster doesn't allow incoming connections.

For `delete: true`, the integration will delete the `skupper-site` config map, *site-controller*, *connection-tokens* secrets, and Skupper services.

## Details

### Definitions

* A **public** cluster is publicly accessible
* An **internal** cluster is not publicly accessible and is behind the VPN
* An **edge** cluster (site-config `edge: true`) doesn't allow incoming Skupper site connections.
* A **non-edge** cluster (site-config `edge: false`) allows incoming Skupper site connections.

### Site Controller Deployment

The *site-controller* is a Kubernetes deployment similar to the one used in the [POC](https://gitlab.cee.redhat.com/service/app-interface/-/blob/4751dee2c4ed02e5a3fbde4617074c508bf74e6c/resources/skupper-cassing/skupper/site-controller.yml).

### Site connections

Skupper site connections have several constraints to be fulfilled:

* Public clusters cannot access internal clusters behind the VPN
* Internal clusters may access other internal clusters (only when peered together)
* A connection token from the cluster you want to connect to needs to be available and valid
* There is no need to bidirectional connect sites. Cluster A connects to B, but B doesn't need to connect to A.

Apply these rules to create the connections:

| Public/Private + internal | Edge                         | Rule                                                                                                 |
| ------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------- |
| public                    | false                        | Connect to all **other** public clusters (lexicographical order)                                     |
| private & not internal    | false (but private exposure) | Connect to all public clusters + all **other** peered & private/not-internal (lexicographical order) |
| private & internal        | true                         | Connect to all public clusters + all peered & private/not-internal                                   |

### Monitoring

The *skupper-router* exposes some prometheus metrics (:9000/metrics), but unfortunately, these are all Apache Qpid (message queue) specific and don't have any Skupper-related information.
The *skupper-service-controller* exposes Skupper-related information as JSON via HTTP (:8888/DATA); the Skupper web console also uses this data. I recommend implementing a "JSON to prometheus metrics" proxy and having alerts based on those metrics:

* Number of connected sites (`len(sites)`)
* An increase of the `GET:50*` counters

The proxy can be decommissioned as soon as Skupper has [native prometheus metrics support](https://github.com/skupperproject/skupper/issues/951).

```json
{
  "sites": [
    {
      "site_name": "appsres03ue1-skupper-vault",
      "site_id": "0f32f434-c47c-47d5-aad5-c45004d32061",
      "version": "1.2.0",
      "connected": [
        "e0f79577-bf92-437f-85e9-ab66ce071cf1"
      ],
      "namespace": "skupper-vault",
      "url": "",
      "edge": true,
      "gateway": false
    },
    {
      "site_name": "app-sre-stage-01-skupper-vault-net",
      "site_id": "e0f79577-bf92-437f-85e9-ab66ce071cf1",
      "version": "1.2.0",
      "connected": [],
      "namespace": "skupper-vault-net",
      "url": "skupper-inter-router-skupper-vault-net.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com",
      "edge": false,
      "gateway": false
    },
    {
      "site_name": "app-sre-stage-02-skupper-vault-net",
      "site_id": "b626627f-9bad-4405-9a5a-da3ab96c7063",
      "version": "1.2.0",
      "connected": [
        "e0f79577-bf92-437f-85e9-ab66ce071cf1"
      ],
      "namespace": "skupper-vault-net",
      "url": "skupper-inter-router-skupper-vault-net.apps.app-sre-stage-0.e9a2.p1.openshiftapps.com",
      "edge": false,
      "gateway": false
    }
  ],
  "services": [
    {
      "address": "vault",
      "protocol": "http",
      "targets": [
        {
          "name": "vault-appsres03ue1-5657854bcb-nl4jq",
          "target": "vault",
          "site_id": "0f32f434-c47c-47d5-aad5-c45004d32061"
        },
        ...
      ],
      "requests_received": [
        {
          "site_id": "e0f79577-bf92-437f-85e9-ab66ce071cf1",
          "by_client": {
            "10.128.10.14": {
              "requests": 2797,
              "bytes_in": 307670,
              "bytes_out": 514519,
              "details": {
                "GET:200": 2796,
                "GET:503": 1
              },
              "latency_max": 212,
              "by_handling_site": {
                "": {
                  "requests": 1,
                  "bytes_in": 110,
                  "bytes_out": 55,
                  "details": {
                    "GET:503": 1
                  },
                  "latency_max": 14
                },
                "0f32f434-c47c-47d5-aad5-c45004d32061": {
                  "requests": 2796,
                  "bytes_in": 307560,
                  "bytes_out": 514464,
                  "details": {
                    "GET:200": 2796
                  },
                  "latency_max": 212
                }
              }
            }
          }
        },
        ...
      ],
      "requests_handled": [
        {
          "site_id": "0f32f434-c47c-47d5-aad5-c45004d32061",
          "by_server": {
            "vault-appsres03ue1-5657854bcb-nl4jq": {
              "requests": 2127,
              "bytes_in": 391368,
              "bytes_out": 233970,
              "details": {
                "GET:200": 2127
              },
              "latency_max": 27
            },
            "vault-appsres03ue1-5657854bcb-sdcln": {
              "requests": 2513,
              "bytes_in": 462024,
              "bytes_out": 276430,
              "details": {
                "GET:200": 2511,
                "GET:500": 2
              },
              "latency_max": 210
            },
            "vault-appsres03ue1-5657854bcb-vxxcd": {
              "requests": 1546,
              "bytes_in": 284464,
              "bytes_out": 170060,
              "details": {
                "GET:200": 1546
              },
              "latency_max": 21
            }
          },
          "by_originating_site": {
            "b626627f-9bad-4405-9a5a-da3ab96c7063": {
              "requests": 3082,
              "bytes_in": 566904,
              "bytes_out": 339020,
              "details": {
                "GET:200": 3081,
                "GET:500": 1
              },
              "latency_max": 27
            },
            "e0f79577-bf92-437f-85e9-ab66ce071cf1": {
              "requests": 3104,
              "bytes_in": 570952,
              "bytes_out": 341440,
              "details": {
                "GET:200": 3103,
                "GET:500": 1
              },
              "latency_max": 210
            }
          }
        }
      ]
    }
  ]
}
```

## Limitations and Open Topics

* [custom annotations on skupper deployments](https://github.com/skupperproject/skupper/issues/930)
* [skupper-router restart leads to network interruption](https://github.com/skupperproject/skupper/issues/940)
* [service-controller prometheus metrics](https://github.com/skupperproject/skupper/issues/951)

### Certificate Management

Skupper (1.1.1) doesn't implement [certificate management yet](https://github.com/skupperproject/skupper/issues/941). Most certificates are valid for five years, except the console web certificates.

| **Secret**                           | **Valid until**          |
| ------------------------------------ | ------------------------ |
| **skupper-claims-server.crt**        | Sep  1 09:32:13 2027 GMT |
| **skupper-console-certs.crt**        | Sep  1 09:35:03 2024 GMT |
| **skupper-local-ca.crt**             | Aug 31 12:21:13 2027 GMT |
| **skupper-local-client.crt**         | Aug 31 12:21:14 2027 GMT |
| **skupper-local-server.crt**         | Aug 31 12:21:14 2027 GMT |
| **skupper-router-console-certs.crt** | Sep  1 09:35:01 2024 GMT |
| **skupper-service-ca.crt**           | Aug 31 12:21:14 2027 GMT |
| **skupper-site-ca.crt**              | Aug 31 12:21:13 2027 GMT |
| **skupper-site-server.crt**          | Aug 31 12:21:20 2027 GMT |

Unfortunately, to renew the certificates, you must delete and re-initiate the skupper site and all skupper connection links again; this means a significant (~5 minutes) skupper service interruption!

Alternatively, you can manage the certificates on your own (e.g., via cert-manager), but it brings all the certificate management burdens.

The integration can deploy [x509-exporter](https://github.com/enix/x509-certificate-exporter) to monitor the expiration dates of all involved certificates.

## Milestones

* [ ] AppSRE team approval
* [ ] Implementation of the qontract-reconcile integration
* [ ] Implementation of a prometheus exporter (see [Monitoring](#monitoring))
* [ ] Deployment of [x509-exporter](https://github.com/enix/x509-certificate-exporter) to monitor certificates
* [ ] Use for grafana -> prometheus connections
* [ ] Cleanup [skupper-example](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/skupper-cassing) from app-interface

## Links

* [Skupper design doc](skupper.md)
