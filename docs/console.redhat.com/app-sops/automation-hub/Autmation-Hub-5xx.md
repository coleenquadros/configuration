Automation Hub 5xx Errors
==========================

Severity: Info
--------------

Impact
------

-   Automation Hub provides a portal to search for and access Ansible Content Collections supported by Red Hat and Ansible Partners via the Certified Partner Program. If a high rate of requests are failing, the core feature of this service is in bad shape.

Summary
-------

This alert fires when the api requests errors out too much.

Access required
---------------

Automation Hub:
-   Access to the ([Production][openshift-prod]|[Stage][openshift-stage]) Openshift cluster to view the
    automation-hub-(prod|stage) namespace.
-   Access to the ([Production][kibana-prod]|[Stage][kibana-stage]) Kibana instance in order to review logs.
-   Access to the ([Production][grafana-prod]|[Stage][grafana-stage]) Grafana instance to see the current
    failure rate on the dashboard.

  [openshift-stage]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/
  [openshift-prod]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/

  [kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana
  [kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana

  [grafana-stage]: https://grafana.stage.devshift.net/d/0RsHCnNGz/automation-hub?orgId=1&from=now-24h&to=now&refresh=30s&var-datasource=crcs02ue1-prometheus&var-namespace=automation-hub-stage
  [grafana-prod]: https://grafana.app-sre.devshift.net/d/0RsHCnNGz/automation-hub?orgId=1&from=now-24h&to=now&refresh=30s&var-Datasource=crcp01ue1-prometheus&var-namespace=automation-hub-prod


Steps
-----

-   Check the dashboard for a quick status.
-   Check logs / events for pods in the automation-hub-(prod|stage) namespace.
-   Check whether Internal Server Errors (ISE) are occuring, either in the galaxy-api, pulp-content-app, or pulp-worker.
-   If a pulp-content-app pod is experiencing reccuring ISEs caused by `Connection reset by peer` errors, restart/delete the pod to resolve the intermittent connectivity issue.
-   Ping the automation-hub team for further investigation to other ISEs.

Escalations
-----------

See
[https://visual-app-interface.devshift.net/services#/services/insights/automation-hub/app.yml](https://visual-app-interface.devshift.net/services#/services/insights/automation-hub/app.yml)
