# telemeter

Telemeter implements a Prometheus federation push client and server to allow isolated Prometheus instances that cannot be scraped from a central Prometheus to instead perform push federation to a central location.

In the context of OCP 4, telemeter is used to push cluster metrics to the 'infogw' prometheus.

More info here: https://github.com/openshift/telemeter/

The observatorium project (telemeter v2) is the new generation telemetry system. It's [documentation andcan be found on github](https://github.com/observatorium/docs)

![schema](telemeter.png)

# Resources

## Endpoints

| Endpoint | Description | URL |
|---|---|---|
| infogw | telemeter-server | https://infogw.api.openshift.com/ |
| infogw-data | prometheus | https://infogw-data.api.openshift.com/ |
| infogw-proxy | cortex proxy | https://infogw-proxy.api.openshift.com/ |

## Code

### telemeter
| Resource | Location |
|---|---|
| Upstream | https://github.com/openshift/telemeter |
| CI/CD | https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/telemeter/ |
| saas repo | https://gitlab.cee.redhat.com/service/saas-telemeter |

### telemeter-proxy
| Resource | Location |
|---|---|
| Config | https://github.com/observatorium/configuration |
| CI/CD | https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/telemeter/ |
| saas repo | https://gitlab.cee.redhat.com/service/saas-telemeter |

## Dependencies
| Dependency | Description |
|---|---|
| UHC | Authorization of client uploads |
| UHC | UHC prometheus for subscription_labels federation |
