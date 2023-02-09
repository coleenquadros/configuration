# KAS Fleet Manager Grafana dashboards development

KAS Fleet Manager Grafana dashboards definitions' source of truth is located in
the [mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards).

Specifically, they can be found in the
[grafana/saas-dashboards](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards/-/tree/master/grafana/saas-dashboards)
subdirectory, where Grafana dashboard definitions for RHOSAK are located
there as files.

AppSRE's Grafana dashboard definition files are defined there as a file that
specifies a [K8s ConfigMap resource](https://kubernetes.io/docs/concepts/configuration/configmap/)
containing an arbitrary key name in the ConfigMap's `data` section which contains
a [Grafana Dashboard JSON definition](https://grafana.com/docs/grafana/latest/dashboards/json-model/) as its value.

The KAS Fleet Manager Grafana dashboards are available in the AppSRE Grafana
instances:
* [AppSRE's Production Grafana](https://grafana.app-sre.devshift.net/)
* [AppSRE's Stage Grafana](https://grafana.stage.devshift.net/)

The KAS Fleet Manager Grafana dashboards are rolled out to the AppSRE Grafana
instances by having specific commits IDs of the [mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards) referenced in the
[Managed Kafka Dashboards SaaS file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-managed-kafka-dashboards.yaml)
located in AppSRE's [app-interface GitLab repository](https://gitlab.cee.redhat.com/service/app-interface). Different commit IDs can be specified independently between
the Production and Grafana instances.

The [mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards) has a specific workflow to develop Grafana dashboards that must
be followed. Roughly, when you develop a Grafana dashboard the idea is:
1. You write the dashboard assuming the RHOSAK stage environment is used. This
   includes references to datasources and namespaces that are specific to stage.
   The dashboard should be limited to the stage datasource. No multiple
   datasources should be available in a dropdown selector in the dashboard.
1. You contribute the changes in master (through a PR process)
1. You rollout to the Grafana stage instance
1. If you want to rollout the changes for that dashboard to the Grafana
   production instance then you need to create different branches and apply
   a set of modifications
1. You rollout to the Grafana stage instance

See the full details of the workflow process in the
[mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards) [README file](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards/-/blob/master/README.md)

Grafana dashboards can query data from the defined data sources.
More information about the datasources available can be found in the
following [link](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/monitoring.md#adding-datasources). When working on the dashboards
make sure that your panels can successfully query data from the appropriate
datasource/s, verifying that data is appropriately displayed.
If your dashboards are including information from new KAS Fleet Manager
Prometheus metrics make sure that the code in KAS Fleet Manager that
implements the addition of those metrics has been deployed in its corresponding environment/s for which you are developing Grafana dashboards for.

## Update an existing Grafana dashboard

To update a new Grafana dashboard go to AppSRE's Production or Stage Grafana
web UI depending on in what environment the dashboard you want to
update is available:

* [AppSRE's Production Grafana](https://grafana.app-sre.devshift.net/)
* [AppSRE's Stage Grafana](https://grafana.stage.devshift.net/)

You can check whether a given Grafana Dashboard is available in Production
Grafana or Stage Grafana by checking whether the commit ID referenced in the
[Managed Kafka Dashboards SaaS file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-managed-kafka-dashboards.yaml) to the desired corresponding environment contains the desired dashboard with
the desired content.

Existing Grafana Dashboards can be edited safely from the UI without impacting
other users as the option to save existing dashboards inplace is disabled.

When you are interested on updating an existing Grafana dashboard, independently
of what environment are you interested on rolling out the changes, you should
update the stage Grafana dashboard always.

Once logged in AppSRE's Grafana Stage Web UI you can find the desired
dashboard in several ways:
* By looking for its name: Press the 'search' icon, search for the desired
  dashboard name and then selecting it. In case you don't know the
  dashboard name you can look at the file definition in the app-interface
  repository and look for the `title` attribute in the top-level of the Grafana
  dashboard JSON definition
* Going to the `RHOSAK` Grafana folder: From the Grafana UI's main
  page, look for the `RHOSAK` folder. There you will see KAS Fleet Manager
  related Grafana dashboards.

Once you are in the desired dashboard you can perform direct modifications on the
existing panels or you can add new panels by pressing the `Add Panel` icon
available on the top part of the Grafana Dashboard.

When all the desired changes to the existing Grafana Dashboard have been applied
the dashboard can be exported. To export a dashboard
* Press the `share` icon on the top-left part of the dashboard
* Go to the `Export` tab
* Save the JSON content to a file

Copy the new generated JSON contents on the Grafana Dashboard definition file
in the [mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards). See the [KAS Fleet Manager Grafana dashboards development](#kas-fleet-manager-grafana-dashboards-development) section for details
on the workflow when working on that repository.

Review the differences with `git diff` to check the generated changes are the
desired ones and submit a pull request with the changes.

## Create a new Grafana dashboard

Some tips about creating Grafana dashboards are described in https://gitlab.cee.redhat.com/service/app-interface#add-a-grafana-dashboard. Keep in mind that
the rollout process described there does not apply, as we use a different
process, described in the [mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards).

Once you have the Grafana dashboard definition built contribute it to the [mk-ci-cd/mk-dashboards GitLab repository](https://gitlab.cee.redhat.com/mk-ci-cd/mk-dashboards). See the [KAS Fleet Manager Grafana dashboards development](#kas-fleet-manager-grafana-dashboards-development) section for details
on the workflow when working on that repository.

Make sure the Grafana Dashboard definition file name contains
the `kas-fleet-manager-` prefix as part of the file name.
