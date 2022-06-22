# ACME certificates with Cert-manager

[toc]

## Author/date

Jordi Piriz / 2020-06-01

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4784

## Problem statement

This design doc is meant to define how openshift-acme is going to be replaced by cert-manager.
Two problems are going to be solved.

1. openshift-acme is abandoned and we can not rely on it anymore
2. We need a way to use ACME certificates (lets-encrypt) in our internal clusters. Internal clusters
   are  not reachable from the internet so the ACME provider can not resolve an HTTP challenge. We will
   rely on DNS challenges for that.

## Goals

- Define the approach we are going to use with cert-manager

## Non-Goals

- Define which operator/software to use. This was already discussed

## Proposals

At first, we only agreed to switch the `Route` definitions to `Ingress` and leverage the Ingress to Route
conversion feature that openshift provides. Although this is the prefered path, a second approach using routes is
proposed.

### Switch to Ingress Objects

Openshift allows routes creation through `Ingress` objects [[ref]](https://docs.openshift.com/container-platform/4.10/networking/routes/route-configuration.html#nw-ingress-creating-a-route-via-an-ingress_route-configuration). Basically, the `openshift-controller-manager`
operator reads the `Ingresses` and creates a Route out of the `Ingress` spec.

Defining Ingress objects instead of routes have a lot of advantages.

- Ingress is a native k8s specification while Route is specific to Openshift.
- Ingress specs are supported by multiple utility operators such as cert-mananger or external-dns
- If openshift changes the ingress provider it should comply with the Ingress spec.

As cert-manager fully supports `Ingress`, just adding an annotation to the the manifest is enough to manage the
certificate associated to the `Ingress` host definitions.

Example of how an Ingress manifest with cert-manager managed certificates looks like.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend
  namespace: test-certmanager
  annotations:
    route.openshift.io/termination: edge
    cert-manager.io/cluster-issuer: letsencrypt-http # cert-manager issuer
    haproxy.router.openshift.io/timeout: 5m # annotations are attached to the route
spec:
  rules:
  - host: jpiriz-test-cert-mgr.devshift.net
    http:
      paths:
        ....
  tls:
  - hosts:
    - example.com
    secretName: example-com-secret # Secret where the certificate will be stored
```

On the internal clusters, the spec is the same, but an issuer with a DNS spec shuold be provided. The issuer spec
defines how the ACME challenges need to be solved. In the case of DNS issuers, cert-manager adds the necessary TXT record
to the DNS provider to solve the challenge. Issuer example:

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging-devshift-net
  namespace: <namespace-of-the-ingress>
spec:
  acme:
    email: sd-app-sre@redhat.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: le-staging-account-key
    solvers:
    - selector:
        dnsNames:
          - '*.devshift.net'
      dns01:
        cnameStrategy: None
        route53: # Route 53  provider needs AWS ACCESS KEYS to put TXT records on the hostedZone to solve the challenges.
          region: global
          accessKeyID: AN_ACCESS_KEY
          hostedZoneID: HOSTED_ZONE_ID
          secretAccessKeySecretRef:
            name: <secret-name-with-aws_secret-access_key>
            key: aws_secret_access_key
```

Both resources can be deployed with openshift-resources using the `resource` provider.
This feature could ne be fully used until 4.12 when the support for `destination-ca-certificates` is rolled out in Openshift.
This only affects Routes with `reencrypt` and using a custom `CA` in the backend (vault)

### Using plain Routes

When a Route deployment happens, from `openshiftResources` or from a `saas file`. The resources process will figure out if the route
needs to request an ACME certificate by checking if the route contains the `kubernetes.io/tls-acme: "true"` annotation.

If the Route contains the annotation, a `Certificate.cert-manager.io` object with will be injected in the deployment. This Cert-manager will
request a Certificate to the ACME provider and it will store it a `Secret` in the same namespace where the Route is deployed.

The `cert-utils-operator` will be installed in the clusters to sync the TLS data `Secrets` into `Routes`.

**With this approach, no changes on the manifests are required, just installing both operators and remving openshift-acme is enough to start**
**managing the certificates with cert-manager**

** This approach has been spiked and is working [HERE](https://github.com/app-sre/qontract-reconcile/pull/2486)

### Issuers Configuration

The HTTP issuer could be set cluster wide as the dns is not managed by cert-manager and it does not required additional configuration.
Once the DNS record is directed to the cluster, the challenge will be solved.

DNS issuers differ for each domain/hosted zone and they need a secret with the credentials of the dns provider in the same namespace where
the issuer is located. We can consider setting the `devshift.net` issuer or other common domains as cluster wide if they need to be used in
many namespaces. But specific cases with domains used in just one namespace will need to set the `Issuer` in its own namespace.

## Alternatives Considered

- N/A

## Milestones

- Implement 2nd proposal in app-interface.
- Roll out changes in App-sre managed routes.
- Modify documentation to include the 1st Proposal and enhance the docs of the current Routes approach.
- All certificates used in app-interface are using cert-manager
  - Send comms to tenants and follow up the progress.
