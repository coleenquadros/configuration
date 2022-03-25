# Openshift-ACME on App-SRE clusters

## Overview

App-SRE runs instances of [openshift-acme](https://github.com/tnozicka/openshift-acme) across several namespaces across several openshift clusters. These instances are provisioned as part of the [openshift-acme saas file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/cicd/ci-int/saas-openshift-acme.yaml). [Here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/feee9dbae5191c2f90ade4415692bc0a6e148133/README.md#L53) are directions on how to set up openshift-acme via app-interface. The purpose of openshift-acme is to rotate certificates on openshift "route" resources in its namespace. Openshift Routes can be marked with the `kubernetes.io/tls-acme: true` annotation to indicate that openshift-acme should be mananging them ([example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/6512a27d5dd48b68899b20aafe27a575a3e91a90/resources/services/ocm/integration/service-logs.route.yaml#L5)) Openshift-acme abides by the [acme protocol](https://www.keyfactor.com/blog/what-is-acme-protocol-and-how-does-it-work/).

As of this writing, openshift-acme is intended to be replaced on app-sre clusters with [cert-manager](https://docs.google.com/document/d/1Io_f26Ph9Yomqmx4K1AJkwoB-TLsw9gECWxOJRa3D7o/edit#heading=h.4c9twulgg922) in the future.

## Known Issues

### Domain Paths

App-interface contains several YAML resource files for routes. Openshift routes can be associated to plain hostnames (e.g. somedomain.com) ([example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/dfec65db6577e91885e5974b25c0fab89b79f32c/resources/services/ocm/production/gateway-server.route.yaml#L11)), or to paths of hostnames (e.g. somedomain.com/some/path) ([example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/dfec65db6577e91885e5974b25c0fab89b79f32c/resources/services/ocm/production/service-logs.route.yaml#L11-12)).

However, it seems openshift router pods on app-sre clusters only map plain hostnames to certificates, and ignores any path completely. Consequently, if multiple route resources exist in the same namespace, and these routes share the same hostname but use different paths, only a single hostname-to-certificate mapping will actually be functional on the openshift-router. The certificate of that one mapping will apply to EVERY route associated with that hostname. This is very unintuitive, and is not expected behavior! 

This behavior can be observed by attaching a shell to an openshift router pod and checking the `cert_config.map` file. If multiple entries for the same hostname exist, only the topmost certificate-mapping will be applied.

### Openshift Route order status stuck in non-"valid" state

Sometimes, the acme order process for openshift routes will get "stuck". This is indicated by the `openshift.io/status=provisioningStatus.orderStatus` annotation value for the openshift route remaining in the `pending` or `ready` state. When this happens, openshift-acme will fail to rotate the route's certificate. [Here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sops/openshift-acme-stuck.md) is how to fix that.
