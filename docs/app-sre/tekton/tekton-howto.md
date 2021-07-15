# How to bootstrap and use Tekton Pipelines for SaaS file deployments

## Background

This document explains how to use Tekton Pipelines as a pipeline provider for SaaS files.

This work was tracked in https://issues.redhat.com/browse/APPSRE-3187

## Process

1. Bootstrap
1. Usage
1. Monitoring
1. Migration from saas-file-1 (Jenkins provider) to saas-file-2 (Tekton provider)

### Bootstrap

In this section you will create:
- a Namespace to host your Tekton Pipelines
- a Pipeline Provider to reference from SaaS files
- a Role to obtain access to the Namespace

Perform the following actions in a single MR:

1. Create a Namespace file:

    ```yaml
    ---
    $schema: /openshift/namespace-1.yml

    labels:
      provider: tekton

    name: <service_name>-pipelines
    description: <service_name> pipelines namespace

    cluster:
      $ref: /openshift/appsrep05ue1/cluster.yml

    app:
      $ref: /services/app-sre/app.yml

    environment:
      $ref: /products/app-sre/environments/production.yml

    managedRoles: true

    # choose a size suitable for the amount of deployed resources
    # the bigger the template, the bigger the size
    # start with large and grow if you see OOMKill events
    limitRanges:
      $ref: /dependencies/openshift/limitranges/pipelines-resource-limits-large.yml

    managedResourceTypes:
    - Secret
    - Task
    - Pipeline
    - ClusterRole

    sharedResources:
    - $ref: /services/app-interface/shared-resources/app-sre-pipelines.yml
    ```

    * this file should be placed under `data/services/<service_name>/namespaces`.
    * copy the file as is and change only the service_name and the cluster:
        * use `appsre05ue1` for internal workloads (behind RH VPN, has access to gitlab). this will replace ci-int.
        * use `app-sre-prod-01` for external workloads. this will replace ci-ext.

2. Create a Pipelines Provider to reference the pipelines namespace:

    ```yaml
    ---
    $schema: /app-sre/pipelines-provider-1.yml

    labels: {}

    name: tekton-<service_name>-pipelines-appsrep05ue1
    description: tekton provider in the <service_name>-pipelines namespace in the appsrep05ue1 cluster

    provider: tekton
    namespace:
      $ref: /services/<service_name>/namespaces/<service_name>-pipelines.appsrep05ue1.yaml

    retention:
      days: 7 # maximum number of days to retain deployments
      minimum: 100 # minimum number of deployments to retain
    ```

    * this file should be placed under `data/services/<service_name>/pipelines`.
    * copy the file as is and change only the service_name and the namespace reference to match the location of the pipelines namespace file.

3. Create a Role to obtain access to view the pipelines namespace and to trigger deployments:

    ```yaml
    ---
    $schema: /access/role-1.yml

    labels: {}
    name: <service_name>-pipelines-appsrep05ue1-access

    permissions: []

    access:
    - namespace:
        $ref: /services/<service_name>/namespaces/<service_name>-pipelines.appsrep05ue1.yaml
      role: view
    - namespace:
        $ref: /services/<service_name>/namespaces/<service_name>-pipelines.appsrep05ue1.yaml
      role: tekton-trigger-access
    ```

    * copy the file as is and change only the `service_name` and the `namespace` references to match the location of the pipelines namespace file.
    * add this role under the `roles` section of the team's user files, or add the `access` entries to an existing role.


### Usage

Perform the following actions in a separate MR from the bootstrap MR:

1. Add a `pipelinesProvider` section to your SaaS file (only available for the `saas-file-2` schema):

    ```yaml
    pipelinesProvider:
      $ref: /services/<service_name>/pipelines/<service_name>-pipelines.appsrep05ue1.yaml
    ```

    * for more information of SaaS files please follow [Continuous Delivery in App-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md).

### Monitoring

For every PipelineRun completed there's a metric that is pushed to Prometheus: `app_sre_tekton_pipelinerun_task_status`. It keeps a translation of the tekton status:

|Tekton Status|Prometheus value|
|-------------|----------------|
| Succeeded   | 0              |
| Failed      | 1              |
| None        | 3              |

The most important labels to identify our PipelineRun are:

* `saas_file_name`: The `name` key in the saas file yaml definition.
* `env_name`: The environment associated to every namespace where the pipeline run deployed openshift objects.

Those two will help you to identify the pipelinerun associated to the deployment.

This is an example of a time series metric from a pipelinerun:

```
app_sre_tekton_pipelinerun_task_status{
  container="pushgateway",
  endpoint="scrape",
  env_name="app-interface-production",
  job="openshift-saas-deploy-push-metric",
  namespace="app-sre-observability-production",
  pipeline_name="openshift-saas-deploy",
  pipelinerun_name="saas-qontract-reconcile-app-interface-production-202106070856",
  pod="pushgateway-5-dkksf",
  saas_file_name="saas-qontract-reconcile",
  service="pushgateway-nginx-gate",
  task_name="openshift-saas-deploy",
  tkn_cluster_console_url="https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com",
  tkn_namespace_name="app-sre-pipelines"}
```

In order to properly search for it you have to use the above labels:

```
app_sre_tekton_pipelinerun_task_status{saas_file_name="saas-qontract-reconcile",env_name="app-interface-production"}
```

The `pipelinerun` label will help you identify the specific pipelinerun associated to this metric, but since this is a metric that is added to Prometheus via the PushGateway, it will be overwritten by subsequent runs of the saas deploy pipeline run so it is not a good candidate to build a query.

[Here](/resources/observability/prometheusrules/app-sre-openshift-saas-deployment-jobs.prometheusrules.yaml) you have an example an example of an alert based on the above metric. There are two important details about it:

* Since the PushGateway runs in [`app-sre-prod-01`](/data/openshift/app-sre-prod-01/cluster.yml), the PrometheusRule will need to be deployed in that cluster.
* The pipelines provider associated to your saas file will tell you exactly where to look for details on your pipeline runs.
* Alternatively, you have the `tkn_cluster_console_url` and the `tkn_namespace_name` labels to have those details. The alert above uses them to build a direct access to the PipelineRun associated to the metric.

### Migration

Perform the following actions in a separate MR from the bootstrap MR:

1. Change the SaaS file schema from `saas-file-1` to `saas-file-2`.
2. Replace the `instance` section with a `pipelinesProvider` as described in the Usage section.
3. Replace every `upstream` field with an `upstream` section:
    * `instance` - reference to Jenkins instance where upstream job exists
    * `name` - name of the Jenkins job to use as upstream (deploy upon build success)

Note: to receive Slack notifications, invite @app-sre-bot to the channel specified in the slack section of the SaaS file.
