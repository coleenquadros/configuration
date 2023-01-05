# OpenShift Pipelines

[TOC]

## Overview

Red Hat OpenShift Pipelines is a continuous integration and continuous
delivery (CI/CD) solution based on Kubernetes resources. It uses Tekton building blocks
to automate deployments across multiple platforms by abstracting away the underlying
implementation details. OpenShift Pipelines can be installed on OCP clusters as an
operator.

See
the [docs](https://docs.openshift.com/container-platform/4.11/cicd/pipelines/understanding-openshift-pipelines.html)
for more information.

## SOPs

### Upgrading OpenShift Pipelines

There are a few helpful points before approaching an upgrade of the OpenShift Pipelines
operator:

1. The operator is installed with [OLM](https://olm.operatorframework.io/docs/)
2. The channels are version-specific at the moment, so for instance to upgrade from
   version 1.7 to 1.8, you'll need to change the `channel` in the `Subscription`
3. OpenShift Pipelines is used to run pipelines associated
   with [SaaS files](/docs/app-sre/continuous-delivery-in-app-interface.md) in addition
   to other services that have declared it as a dependency

#### Known issues

##### TaskRuns delayed during/after upgrade

While not technically an "issue", it has been observed that upgrading OpenShift
Pipelines while there are `PipelineRuns` in progress can result in a delay before the
next `TaskRun` starts. This delay was observed to be roughly 10 minutes.
All `PipelineRuns` will eventually complete as expected as long as they do not timeout
with this additional 10 minutes.

##### Failure to upgrade CSV

The `stable` channel used to exist for OpenShift Pipelines, but it has since been
replaced with version specific channels and a `latest` channel. In only one case
(out of 4), after the channel was removed, and the `Subscription` was changed to a
supported channel, the upgrade failed to ever make progress. To get this working it was
necessary to delete the CSV (`oc delete csv`) in order for OpenShift Pipelines to be
upgraded. This is a variation of the [OLM dance](/docs/app-sre/olm-troubleshooting.md)
because we didn't need to also delete the `Subscription`.

#### Example upgrade schedule

See [APPSRE-6401](https://issues.redhat.com/browse/APPSRE-6401) for an example of the
schedule to follow. This may change with time as the operator is installed on additional
clusters, so consider this only as a starting point.

#### Upgrade steps

The process for upgrading is simple:

1. Read the OpenShift Pipeline release notes (see the docs in overview) to ensure that
   there aren't any breaking changes. You may need to update the `TektonConfig` (also
   managed by app-interface) if there are any configurations that have changed or been
   removed.
2. Change the `channel` in the `Subscription` to match the version that you wish to
   upgrade
   to ([example](/resources/tekton/openshift-pipelines-operator-rh-1-7.subscription.yaml))
3. Merge the MR and run the following command to ensure that the CSV was
   updated `oc get csv -n openshift-operators`
4. Observe the `PipelineRuns` (`oc get pipelineruns` or use the UI) to ensure that there
   aren't any failures. If the cluster being upgraded doesn't run pipelines frequently (
   stage environments), you can rerun the last `PipelineRun` to ensure that everything
   works as expected.

## Support

The [#forum-tektoncd-pipelines](https://coreos.slack.com/archives/CSPS1077U) Slack
channel can be used for asking general questions about OpenShift Pipelines. Beyond that,
AppSRE is generally responsible for managing the operator on our clusters.
