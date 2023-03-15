## MK Observability Remote Write Proxy down

### Context

[Observability Remote Write Proxy](https://github.com/bf2fc6cc711aee1a0c2a/observability-remote-write-proxy)
is a component of the RHOSAK product located on the control plane side.

Data Planes in the RHOSAK product send a set of Prometheus metrics to
Observatorium. In order to do so, they do it indirectly by making use of the
Observability Remote Write Proxy component.

By using Observability Remote Write Proxy RHOSAK avoids needing to store
Observatorium credentials in the Data Planes managed by KAS Fleet Manager.

Observability Remote Write Proxy acts as a proxy between the Data Planes
sending metrics and Observatorium. Specifically, it forwards Prometheus
Remote Write requests sent from the Data Planes to Observatorium, performing
additional authorization and validation checks.

Data that goes through Remote Write Proxy is used to perform customers billing
and to get observability on the data planes side, which the users can also
access.

Observability Remote Write Proxy is a stateless component and it is deployed
through a K8s Deployment where its pods are located behind a K8s Service.
See the
[KAS Fleet Manager SaaS template](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/managed-services/cicd/saas/saas-kas-fleet-manager.yaml) for details on its definition.
The Observability Remote Write Proxy pods have a readiness probe against
the `/healthcheck` endpoint of Observability Remote Write Proxy.

When a request is received to Observability Remote Write Proxy several
dependencies are involved aside from the Data Planes themselves sending the
data to it:
* KAS Fleet Manager: Once the request arrives to the proxy, communication
  with KAS Fleet Manager is initiated by the proxy to perform authorization
  related tasks
* Observatorium: The metrics sent from the data planes to the proxy
  are ultimately sent to Observatorium in case the request to the proxy is
  authorized. To be able to do so, the proxy retrieves OIDC
  bearer tokens by contacting Red Hat SSO with a client_id/client_secret pair.
  The client_id/client_secret information is stored in a K8s secret that
  the proxy mounts.
* Red Hat SSO: Used by the proxy to retrieve OIDC tokens to be able to send
  the received metrics to Observatorium

### Impact

Data from the Prometheus Data Planes can not be received by Observability
Remote Write Proxy and therefore that data can not be sent to Observatorium.

Metrics are used to have observability and also to perform customers billing.

If this happens, several issues arise:
* Billing metrics are not able to be sent to Observatorium and therefore
  Billing in RHOSAK does not work which means that customers are not billed
* RHOSAK related Grafana dashboards and Prometheus metrics will stop receiving
  new data, impacting Observability of the service
* Customers making use of RHOSAK user-facing metrics will stop
  receiving new data, impacting user experience

### Summary

The MK Observability Remote Write Proxy (Pods) is down.

### Access required

- OSD console access to the cluster that runs the Managed Kafka Observability
  Remote Write Proxy
- Access to cluster resources: Pods/Deployments/Events.

### Relevant secrets

### Steps

The cause(s) of Observability Remote Write Proxy being down might be due to
several reasons: it might be due to issues with the infrastructure where
it is located or due to issues with the component itself.

The following actions can be performed to gain insights on the cause of the issue:
* Check the state of the K8s deployment of Observability Remote Write Proxy
  and look for errors or issues in there
* Check K8s events looking for potential warnings and errors related to it
* Check the K8s Pod logs of the Observability Remote Write Proxy. Potential
  bugs in the code of the proxy, failure communicating with the proxy dependencies,
  etc. might be identified
* Check whether the readiness probe of the Observability Remote Write Proxy pods
  is passing
* Check whether the scrape endpoint of the Observability Remote Write Proxy pods
  is passing

After gathering that information, if the issue is related to an infrastructure
issue then AppSRE should solve it or escalate it to the team that is the
designed to deal with those infrastructure related issues. If the issue is
related due to the issues with the component itself escalate it to the
RHOSAK Control Plane team providing all the observed information. In the
later case, see the [Escalations](#escalations) section.

## Escalations

If the problem cannot not be solved and it is related to the Observability
Remote Write Proxy component itself and not due to infrastructure issues
escalate the issue to the Control Plane team. Escalation policy can be found
[here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/managed-services/escalation-policies/kas-fleet-manager.yaml)

