# telemeter

Telemeter implements a Prometheus federation push client and server to allow isolated Prometheus instances that cannot be scraped from a central Prometheus to instead perform push federation to a central location.

In the context of OCP 4, telemeter is used to push cluster metrics to the 'infogw' prometheus.

More info here: https://github.com/openshift/telemeter/

![schema](telemeter.png)

# Resources

## Endpoints

| Endpoint | Description | URL |
|---|---|---|
| infogw | telemeter-server | https://infogw.api.openshift.com/ |
| infogw-data | prometheus | https://infogw-data.api.openshift.com/ |
| infogw-cache | prometheus (cache) | https://infogw-cache.api.openshift.com/ |

## Code

### telemeter
| Resource | Location |
|---|---|
| Upstream | https://github.com/openshift/telemeter |
| CI/CD | https://ci.ext.devshift.net/view/telemeter/ |
| saas repo | https://github.com/app-sre/saas-telemeter/ |

### telemeter-cache
| Resource | Location |
|---|---|
| Upstream | https://github.com/app-sre/saas-telemeter-cache-manifests/ |
| CI/CD | https://ci.ext.devshift.net/view/telemeter-cache/ |
| saas repo | https://github.com/app-sre/saas-telemeter-cache/ |

## Dependencies
| Dependency | Description |
|---|---|
| UHC | Authorization of client uploads |
