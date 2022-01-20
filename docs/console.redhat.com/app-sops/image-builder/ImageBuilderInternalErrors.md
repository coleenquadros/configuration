ImageBuilderInternalErrors
==========================

Severity: Info
--------------

Impact
------

-   Image Builder is a service used to build images. It acts as an interface for composer. If image
    builds are failing, the core feature of this service is in bad shape.

Summary
-------

This alert fires when the compose request, the request to build an
image, errors out too much.

Access required
---------------

Image-builder:
-   Access to the ([Production][openshift-prod]|[Stage][openshift-stage]) Openshift cluster to view the
    image-builder-(prod|stage) namespace.
-   Access to the ([Production][kibana-prod]|[Stage][kibana-stage]) Kibana instance in order to review logs.
-   Access to the ([Production][grafana-prod]|[Stage][grafana-stage]) Grafana instance to see the current
    failure rate on the dashboard.

Image-builder-composer:
-   Access to the ([Production][openshift-composer-prod]|[Stage][openshift-composer-stage]) Openshift cluster to view the
    image-builder-(prod|stage) namespace.
-   Access to the ([Production][grafana-composer-prod]|[Stage][grafana-composer-stage]) Grafana instance to see the current
    failure rate on the dashboard.

  [openshift-stage]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/
  [openshift-prod]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/
  [openshift-composer-stage]: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/
  [openshift-composer-prod]: https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/

  [kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana
  [kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana

  [grafana-stage]: https://grafana.stage.devshift.net/d/image-builder-crc/image-builder-crc?orgId=1&var-datasource=crcs02ue1-prometheus&var-interval=28d&var-stability_slo=0.95&var-compose_latency_slo=0.9&var-noncompose_latency_slo=0.9
  [grafana-prod]: https://grafana.app-sre.devshift.net/d/image-builder-crc/image-builder-crc?orgId=1
  [grafana-composer-stage]: https://grafana.stage.devshift.net/d/image-builder-composer/image-builder-composer?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-interval=28d&var-stability_slo=0.95&var-latency_slo=0.9
  [grafana-composer-prod]: https://grafana.app-sre.devshift.net/d/image-builder-composer/image-builder-composer?orgId=1

Steps
-----

-   Check the dashboard for a quick status.
-   Check logs / events for pods in the image-builder-(prod|stage)
    namespace.
-   Check where the errors are occuring, either in Image Builder or in
    the Composer service it depends on.
-   Ping the image-builder team

Escalations
-----------

See
[https://visual-app-interface.devshift.net/services#/services/insights/image-builder/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/image-builder/app.yml)
