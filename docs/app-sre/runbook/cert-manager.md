# Cert-manager and app-interface

[TOC]

## Overview

Cert-manager is an operator that manages ACME certificates lifecycle for exposed services in a cluster. It reads `Ingress`
specs and generates TLS certificates automatically for `hosts` used in the Ingress spec. Certificates data is stored
in `Secrets` in the same namespace where the `Ingress` resides.

Openshift uses `Route` objects to expose services. Routes are translated into `ha-proxy` configurations managed by the
openshift ingress pods. Openshift also supports `Ingress` to `Route` specs translation, but some `Route` features
are not achivable using that translation.

Cert-manager has an additionnal `openshift-cert-manager-routes` operator to manage certificates set in `Route` objects.
It requires an additional operator because they can't include `Routes` support directly in the main operator.

The App-Interface approach for ACME certificates provisioning is based on `openshift-cert-manager-routes` along with `cert-manager`.
The configuration on the Routes is the same used for `Ingress` objects with the plain `cert-amanger`. When `cert-manager` annotations
are set in a `Route`, the operator will manage the certificate lifecycle.

## High-Level operator modus-operandi

The operator acts over `Route` objects, it reconciles them continuosly and is informed whenever a `Route` object changes. If a
Route has `cert-manager` annotations, the operator checks the certificate data in the route's `TLS` attribute. If the certificate
has reached 2/3 of its lifetime or there is no certificate, a new certificate is requested.

`openshift-cert-manager-routes` issues certificates using `CertificateRequest` objects. When a new certificate is needed, the operator
createsa `CertificateRequest` object with the required data (CSR) and then `cert-manager` requests the certificate to the issuer. Once
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
Access keys to the issuer or by the Metadata Server using IRSA, kube2iam or similars.

## How to install and configure cert-manager in an openshift cluster

### External Cluster

1. (1st MR) Install redhat-cert-manager operator with OLM [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/app-sre-stage-02/namespaces/openshift-operators.yaml#L22-L23).
    - This will install `cert-manager` in the `openshift-cert-manager` namespace.

2. (2nd MR) Install `openshift-cert-routes` into `openshift-cert-manager` namespace [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L53-L55)
    - 1st MR needs to be merged to ensure the namespace is created.
    - `openshift-cert-routes` operator needs to be deployed into the same namespace as `cert-manager`

3. (2nd MR) Install the HTTP-01 ClusterIssuer [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/openshift/app-sre-stage-02/namespaces/openshift-cert-manager.yml)
    - 1st MR needs to be merged to ensure the namespace is created.
    - This is a Cluster resource. Bound to this namespace in A-I for coherence.

### Private Clusters (Not reachable from Internet)

1. (1st MR) Install redhat-cert-manager operator with OLM [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L53-L55).
    - This will install `cert-manager` in the `openshift-cert-manager` namespace.

2. (2nd MR) Install `openshift-cert-routes` into `openshift-cert-manager` namespace [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L53-L55)
    - 1st MR needs to be merged to ensure the namespace is created.
    - `openshift-cert-routes` operator needs to be deployed into the same namespace as `cert-manager`

3. (3nd MR) Create a service account to interact with Route53 [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/openshift/appsres03ue1/namespaces/openshift-cert-manager.yml#L27-L63)
    - Follow the same name structure of the example (identifier and output_resource_name)
    - This step can be made within the 2nd MR, but it's preferable to split these tasks.

4. (4rt MR) Create the DNS-01 ClusterIssuer [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c42c0d0c06cb51efcf9d3b889333d7c3e60f21dc/data/openshift/appsres03ue1/namespaces/openshift-cert-manager.yml#L65-L76)
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

## Additional Information

- [cert-manager](https://cert-manager.io/)
- [cert-manager-openshift-routes](https://github.com/cert-manager/openshift-routes)
