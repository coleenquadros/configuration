# Cert-manager and app-interface

[TOC]

## Overview

Cert-manager is an operator that manages ACME certificates lifecycle for exposed services in a cluster. It reads `Ingress`
specs and generates TLS certificates automatically for `hosts` used in the Ingress spec. Certificates data is stored
in `Secrets` in the same namespace where the `Ingress` resides.

Openshift uses `Route` objects to expose services. Routes are translated into `ha-proxy` configurations managed by the
openshift router pods. Openshift also supports `Ingress` to `Route` specs translation, but some `Route` features
are not achievable using that translation.

Cert-manager has an additional `openshift-cert-manager-routes` operator to manage certificates set in `Route` objects.
It requires an additional operator because they can't include `Routes` support directly in the main operator.

The App-Interface approach for ACME certificates provisioning is based on `openshift-cert-manager-routes` along with `cert-manager`.
The configuration on the Routes is the same used for `Ingress` objects with the plain `cert-manager`. When `cert-manager` annotations
are set in a `Route`, `openshift-cert-manager-routes` will manage the certificate lifecycle.

## High-Level operator modus-operandi

`openshift-cert-manager-routes` acts over `Route` objects, it reconciles them continuously and is informed whenever a `Route` object changes. If a
Route has `cert-manager` annotations, the operator checks the certificate data in the route's `TLS` attribute. If the certificate
has reached 2/3 of its lifetime or there is no certificate, a new certificate is requested.

`openshift-cert-manager-routes` requests certificates using `CertificateRequest` objects. When a new certificate is needed, the operator
creates a `CertificateRequest` object with the required data (CSR) and then `cert-manager` requests the certificate to the issuer. Once
the request is ready, the operator updates the `Route` with the new certificate data.

## ACME issuers

`cert-manager` supports multiple issuers and types of challenges. App-interface uses `HTTP-01` challenges with external clusters,
and `DNS-01` challenges with private/internal clusters.

External clusters are deployed with a letsencrypt `HTTP-01` `ClusterIssuer` named `letsencrypt-prod-http` that can be used with any `host`.
When using this issuer, the operator creates a solver `Pod` and a http `Route` to solve the challenge. Once the certificate is fetched,
both resources are removed from the cluster.

Private clusters (and clusters not reachable from internet) need a `DNS-01` issuer as the certificates provider can not reach the `HTTP-01` solver endpoint
via internet. DNS issuers create a `TXT` dns record and then the certificates provider does a DNS resolution to solve the challenge.

App-interface private clusters are deployed with a `DNS-01` ClusterIssuer **configured to work with the devshift.net domain only** named
`letsencrypt-devshiftnet-dns`. `Routes` using `devshift.net` domain can use this `ClusterIssuer`, if a tenant wants to get certificates for
other domains, they must create an `Issuer` with the required configuration in its namespace and use that issuer on their `Routes`.

An important note with DNS Issuers is that they need to authenticate with the DNS provider, in the Route53 case this can be achieved either by providing
Access keys to the issuer or by the Metadata Server using IRSA, kube2iam or similar tools.

## How to install and configure cert-manager in an openshift cluster

### External Cluster

1. 1st MR: Install redhat-cert-manager operator with OLM [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/app-sre-stage-02/namespaces/openshift-operators.yaml#L22-L23).
    - This will install `cert-manager` in the `openshift-cert-manager` namespace.

2. 2nd MR:
    - Install `openshift-cert-routes` into `openshift-cert-manager` namespace [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L53-L55)
      - 1st MR needs to be merged to ensure the namespace is created.
      - `openshift-cert-routes` operator needs to be deployed into the same namespace as `cert-manager`
      - the `openshift-cert-manager` namespace file manifest in app-interface must be created manually within this MR, the operator just creates the namespace.
    - Install the `HTTP-01` ClusterIssuer [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/openshift/app-sre-stage-02/namespaces/openshift-cert-manager.yml)
      - This is a Cluster resource. Bound to this namespace in A-I for coherence.

### Private Clusters (Not reachable from Internet)

1. 1st MR: Install redhat-cert-manager operator with OLM [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L53-L55).
    - This will install `cert-manager` in the `openshift-cert-manager` namespace.

2. 2nd MR: Install `openshift-cert-routes` into `openshift-cert-manager` namespace [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L53-L55)
    - 1st MR needs to be merged to ensure the namespace is created.
    - `openshift-cert-routes` operator needs to be deployed into the same namespace as `cert-manager`

3. 3rd MR: Create a service account to interact with Route53 [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/openshift/appsres03ue1/namespaces/openshift-cert-manager.yml#L27-L63)
    - Follow the same name structure of the example (identifier and output_resource_name)
    - This step can be made within the 2nd MR, but it's preferable to split these tasks.

4. 4th MR: Create the `DNS-01` `ClusterIssuer` [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/openshift/appsres03ue1/namespaces/openshift-cert-manager.yml#L65-L76)
    - the resource-template reads the Secrets from vault (Secrets populated by the previous MR)
    - the 2nd resource is a configuration required by Route53 to only use recursive name-servers. This validation is made by the operator. Before creating the ACME order
      it checks that the `host` exists in the DNS provider.

## How to configure Routes to use cert-manager

Routes just need to have the cert-manager required annotations.

### External clusters using the default ClusterIssuer

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    cert-manager.io/issuer-kind: ClusterIssuer
    cert-manager.io/issuer-name: letsencrypt-prod-http
  name: prometheus-app-sre
spec:
  ...
```

### Private clusters using the default devshift.net ClusterIssuer

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    cert-manager.io/issuer-kind: ClusterIssuer
    cert-manager.io/issuer-name: letsencrypt-devshiftnet-dns
  name: prometheus-app-sre
spec:
  ...
```

## How to migrate Routes from openshift-acme to cert-manager-routes

Two steps are required to migrate routes from openshift-acme to cert-manager:

- Change route annotations to remove tls annotation and include cert-manager annotations.

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    cert-manager.io/issuer-kind: ClusterIssuer
    cert-manager.io/issuer-name: letsencrypt-prod-http
    kubernetes.io/tls-acme: "true" # <-- THIS LINE SHOULD BE REMOVED, IS NOT USED ANYMORE
```

- Remove openshift-acme deployment from the namespace [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/88ca619f5363bc43f730fa5d34c6e50418d33f28/data/services/app-sre/cicd/ci-int/saas-openshift-acme.yaml#L72-L75)

## Multiple Path-based Routes with the same Host

When multiple secured `Routes` use the same `host`, openshift router uses the same certificate for all of them. In these cases, cert-manager annotations need to be set in one of the routes only.

- [More info](https://redhat-internal.slack.com/archives/CCH60A77E/p1658931732003599)
- [Example](https://gitlab.cee.redhat.com/service/app-interface/-/tree/d005987304a30f981d76f5e042d12097b25d3d83/resources/app-sre-stage/telemeter-stage)


## Troubleshooting

If a certificate is not getting issued or updated, you'll need to check the `cert-manager` objects in the same namespace where the `Route` is deployed.

Example:

```bash
❯ oc get CertificateRequest
NAME                                 APPROVED   DENIED   READY   ISSUER                  REQUESTOR                                                                    AGE
code-quarkus-redhat-api-d-zpvmh      True                False   letsencrypt-prod-http   system:serviceaccount:openshift-cert-manager:cert-manager-openshift-routes   22h

❯ oc describe CertificateRequest code-quarkus-redhat-api-d-zpvmh
Name:         code-quarkus-redhat-api-d-zpvmh
Namespace:    code-quarkus-redhat-stage
[...]
Status:
  Conditions:
    Last Transition Time:  2022-08-03T08:28:19Z
    Message:               Certificate request has been approved by cert-manager.io
    Reason:                cert-manager.io
    Status:                True
    Type:                  Approved
    Last Transition Time:  2022-08-03T08:28:19Z
    Message:               Waiting on certificate issuance from order code-quarkus-redhat-stage/code-quarkus-redhat-api-d-zpvmh-1483473006: "processing"
    Reason:                Pending
    Status:                False
    Type:                  Ready
Events:                    <none>


❯ oc describe Order code-quarkus-redhat-api-d-zpvmh-1483473006
Name:         code-quarkus-redhat-api-d-zpvmh-1483473006
Namespace:    code-quarkus-redhat-stage
Labels:       <none>
[...]
Status:
  Authorizations:
    Challenges:
      Token:        IfimfssUcnPMykdQpQfTcpKlQooTzBiooJEfYUcnnAA
      Type:         http-01
      URL:          https://acme-v02.api.letsencrypt.org/acme/chall-v3/137792422206/ovRWqQ
      Token:        IfimfssUcnPMykdQpQfTcpKlQooTzBiooJEfYUcnnAA
      Type:         dns-01
      URL:          https://acme-v02.api.letsencrypt.org/acme/chall-v3/137792422206/XLIimg
      Token:        IfimfssUcnPMykdQpQfTcpKlQooTzBiooJEfYUcnnAA
      Type:         tls-alpn-01
      URL:          https://acme-v02.api.letsencrypt.org/acme/chall-v3/137792422206/a3SgZg
    Identifier:     code.quarkus.stage.redhat.com
    Initial State:  pending
    URL:            https://acme-v02.api.letsencrypt.org/acme/authz-v3/137792422206
    Wildcard:       false
  Finalize URL:     https://acme-v02.api.letsencrypt.org/acme/finalize/610586596/112686765626
  State:            processing
  URL:              https://acme-v02.api.letsencrypt.org/acme/order/610586596/112686765626
Events:             <none>
```

In this case the problem was that some path-based routes were annotated with the cert-manager annotations multiple times and they were sharing the same
host. If a `CertificateRequest` is not progressing or it has errors, you can delete it to retry the certificate issuance.

## Additional Information

- [cert-manager](https://cert-manager.io/)
- [cert-manager-openshift-routes](https://github.com/cert-manager/openshift-routes)
