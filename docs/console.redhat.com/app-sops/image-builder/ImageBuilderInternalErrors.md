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

-   Access to the ([Production][openshift-prod]|[Stage][openshift-stage]) Openshift cluster to view the
    image-builder-(prod|stage) namespace.
-   Access to the ([Production][kibana-prod]|[Stage][kibana-stage]) Kibana instance in order to review logs.
-   Access to the ([Production][grafana-prod]|[Stage][grafana-stage]) Grafana instance to see the current
    failure rate on the dashboard.

  [openshift-stage]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/
  [openshift-prod]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/

  [kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana
  [kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana

  [grafana-stage]: https://grafana.stage.devshift.net/d/91_RmVCMk/image-builder
  [grafana-prod]: https://grafana.app-sre.devshift.net/d/91_RmVCMk/image-builder
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
