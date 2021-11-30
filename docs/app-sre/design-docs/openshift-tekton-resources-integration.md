---
# Design doc: Openshift tekton resources integration

## Author/date

Rafael Porres Molina (rporresm) / 2021-07-20

## Tracking JIRA

[https://issues.redhat.com/browse/APPSRE-3389](https://issues.redhat.com/browse/APPSRE-3389)

## Problem statement

We need to be able to configure resource consumption to the containers
running the tekton tasks. We currently do not add any limits and the
result is kubernetes not being able to properly schedule pods based on
node resources. When a node is memory overloaded, kubernetes deletes
completed pods, hence removing the logs associated with the tasks.

The memory requirements of saas file deployment pods is not homogeneous.
It goes from 200Mb to around 2.5Gb of the pods deploying grafana
dashboards. We need to be able to configure requests and limits for
every saas file.

Requests and limits are configured at the step level of a Tekton
[`Task`](https://tekton.dev/docs/pipelines/tasks/#defining-steps).
They don't accept parameters that can be passed from a `PipelineRun`. We
need to be able to create different `Pipeline`/`Task`s resources for every
saas file with potential different configurations.

## Objectives

- Saas files will have a way to configure the memory and cpu that
  `openshift-saas-deploy` integration runs need. There will be one
  configuration per saasfile

- The rollout of the solution must be gradual, hence the old solution
  and the new one must be able to coexist

## Non-objectives

- The rest of the steps associated with the `Task`s running the
  deployment won't be configurable. They have a fixed need for
  memory and cpu.

## Proposal

A new integration called `openshift-tekton-resources` will create
`openshift-saas-deploy-<saas_file_name>` `Pipeline` and `Task` resources per
saas file. They will be based on the [current
ones](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/tekton),
with the ability to add resources to the qontract-reconcile step. The
`Pipeline` resource will need to be different for every saas file as it
will need to call a different `Task`.

The new integration will reconcile the state of the Tekton resources for
namespace associated with every pipeline provider. It will have a
similar shape as openshift-resources, reusing all the same functions to
reconcile the desired state of every object. The main difference will be
that the tekton objects associated with every saas file will be built
dynamically based on templates in qontract-reconcile. In order to have
the same shape (and benefit from the already battle tested
openshift-resources related methods), the integration will need to build
a
[namespaces](https://github.com/app-sre/qontract-reconcile/blob/11f35d7d264851b73edd0822ceceea881b44e81c/reconcile/openshift_resources_base.py#L675)
array of dicts similar to what openshift-resources does, but with the
main difference of it not being a direct mapping of objects in
app-interface.

In order to be able to rollout progressively the following actions will
be taken:

- The `configurable_resources` boolean property will be added to the
  `saas-file-2.yml` schema, the new integration only working on the
  saas files that have it set to true

- The current tekton namespaces will define `managedResourceNames` for
  its managed `Pipeline` and `Task` resources so that they don't try to
  manage the resources created by the new integration.

- The integration will only manage its own resources until the rollout
  is complete

- `openshift-saas-deploy-trigger-*` will build the `PipelineRun` resources
  based on the configurable_resources boolean, since the name of the
  `Pipeline` resource will be different.

There's a potential race condition when a new saas file is created and
the corresponding `openshift-saas-deploy-trigger-*` integration tries to
create the `PipelineRun` resource. The new integration might have not
created the corresponding Tekton objects yet. This will need to be
addressed in the
[`openshift_saas_deploy_trigger_base._trigger_tekton`](https://github.com/app-sre/qontract-reconcile/blob/2694fb3533a3c250e88b8e661cfad144c8162a74/reconcile/openshift_saas_deploy_trigger_base.py#L263-L313)
function, so that if the needed `Pipeline` resource does not exist, the
`PipelineRun` resource is not created and the state is not updated, hence
forcing the retry on the next run of the integration.

## Reviews

|Reviewer|Date|Notes|
|---|---|---|
|mafriedm|2021/07/21|LGTM|
|JB|2021/07/21|Thank you for this. This seems like a modular, extensible approach.|
|jmelis|2021/08/16|LGTM|
