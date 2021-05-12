# KAS Fleet Manager Grafana dashboards development

KAS Fleet Manager Grafana dashboards' source of truth is located in [AppSRE's
app-interface GitLab repository](https://gitlab.cee.redhat.com/service/app-interface).

Specifically, they can be found in the
[resources/observability/grafana](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/grafana)
subdirectory, where Grafana dashboard definitions for multiple
services, including KAS Fleet Manager, are located there as files.

An AppSRE's Grafana dashboard definition file is defined there as a file that
specifies a [K8s ConfigMap resource](https://kubernetes.io/docs/concepts/configuration/configmap/)
containing an arbitrary key name in the ConfigMap's `data` section which contains
a [Grafana Dashboard JSON definition](https://grafana.com/docs/grafana/latest/dashboards/json-model/)
as its value.

KAS Fleet Manager Grafana dashboards can be found by looking at the files
that contain the `grafana-dashboard-kas-fleet-manager` prefix as part of their
name.

Grafana dashboards can query data from the defined data sources. More information about
the datasources available can be found in the following [link](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/monitoring.md#adding-datasources). When working on the dashboards make sure that your panels
can successfully query data from the appropriate datasource/s, verifying that
data is appropriately displayed.
If your dashboards are including information from new KAS Fleet Manager Prometheus
metrics make sure that the code in KAS Fleet Manager that implements the addition
of those metrics has been deployed in its corresponding environment/s for which
you are developing Grafana dashboards for.

## Update an existing Grafana dashboard

To update a new Grafana dashboard go to AppSRE's Production or Stage Grafana
web UI depending on in what environment the dashboard you want to update is available:

* [AppSRE's Production Grafana](https://grafana.app-sre.devshift.net/)
* [AppSRE's Stage Grafana](https://grafana.stage.devshift.net/)

Take into account that some dashboards have a shared definition file between
Production and Stage so updating the definition file will make the changes
available in both environments.

You can check whether a given Grafana Dashboard is available in Production
Grafana or Stage Grafana by checking whether its file name is referenced in
the following files:
* [data/services/observability/namespaces/app-sre-observability-production.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/app-sre-observability-production.yml): All Grafana Dashboard definition files
  referenced here will be shown in AppSRE's Production Grafana
* [data/services/observability/namespaces/app-sre-observability-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/app-sre-observability-stage.yml): All Grafana Dashboard definition files
  referenced here will be shown in AppSRE's Stage Grafana

Once logged in AppSRE's Grafana Web UI you can find the desired dashboard in
several ways:
* By looking for its name: Press the 'search' icon, search for the desired
  dashboard name and then selecting it. In case you don't know the
  dashboard name you can look at the file definition in the app-interface
  repository and look for the `title` attribute in the top-level of the Grafana
  dashboard JSON definition
* Going to the `KasFleetManager` Grafana folder: From the Grafana UI's main
  page, look for the `KasFleetManager` folder. There you will see KAS Fleet Manager
  related Grafana dashboards.

Existing Grafana Dashboards can be edited safely from the UI without impacting
other users as the option to save existing dashboards inplace is disabled.

Once you are in the desired dashboard you can perform direct modifications on the
existing panels or you can add new panels by pressing the `Add Panel` icon
available on the top part of the Grafana Dashboard.

When all the desired changes to the existing Grafana Dashboard have been applied
the dashboard can be exported. To export a dashboard
* Press the `share` icon on the top-left part of the dashboard
* Go to the `Export` tab
* Check Export for sharing externally ; This is highly important
* Save the JSON content to a file

Copy the new generated JSON contents on the Grafana Dashboard definition file
in AppSRE's app-interface repository. An easy way to do this is by saving
the new contents in a file with the same name as key name in the
`data` section of the Grafana Dashboard definition file and run the following command:
```
oc create configmap <configmap-name> --from-file=<exported-grafana-dashboard-json-contents-file> -o yaml --dry-run > <grafana-dashboard-definition-file>
```
However, following this approach will remove the existing annotations and labels
from the ConfigMap. Make sure you undo those removals.

Review the differences with `git diff` to check the generated changes are the
desired ones and submit a pull request with the changes.

## Create a new Grafana dashboard

Follow the procedure explained in https://gitlab.cee.redhat.com/service/app-interface#add-a-grafana-dashboard.

Make sure the Grafana Dashboard definition file name contains
the `grafana-dashboard-kas-fleet-manager` prefix as part of the file name.
