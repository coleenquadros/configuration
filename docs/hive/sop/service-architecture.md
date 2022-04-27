- [Overview](#overview)
- [Service Description](#service-description)
  - [OSD Operators](#osd-operators)
  - [Environments](#environments)
  - [Continuous Deployment](#continuous-deployment)
    - [Build](#build)
    - [SaaS Deployment](#saas-deployment)
    - [Promoting to Production](#promoting-to-production)
- [Components](#components)
  - [HiveConfig](#hiveconfig)
  - [Operator Namespace and `hive-operator`](#operator-namespace-and-hive-operator)
  - [Controller Namespace and controllers](#controller-namespace-and-controllers)
    - [`hive-controllers` Deployment](#hive-controllers-deployment)
    - [`hive-clustersync` StatefulSet](#hive-clustersync-statefulset)
    - [`hiveadmission` Deployment](#hiveadmission-deployment)
- [Routes](#routes)
- [Dependencies](#dependencies)
- [Service Diagram](#service-diagram)
- [Application Success Criteria](#application-success-criteria)
- [State](#state)
- [Load Testing](#load-testing)
- [Capacity](#capacity)

## Overview
[Hive](https://github.com/openshift/hive) is a Kubernetes operator that knows how to:
- Provision OpenShift clusters into various cloud providers via the [OpenShift installer](https://github.com/openshift/installer)
- Perform day-2 operations by reconciling objects into the hosted cluster

See the [Project Documentation](https://github.com/openshift/hive/blob/master/README.md) for more.

Contact the Hive development team in [#forum-hive](https://coreos.slack.com/archives/CE3ETN3J8) on CoreOS slack.

## Service Description
The [hive service](https://visual-app-interface.devshift.net/services#/services/hive/app.yml) in AppSRE is used by the SRE-Platform (SREP) team to provision, maintain, and monitor clusters for the OpenShift Dedicated (OSD) product, a managed service built on OpenShift Container Platform (OCP).
One instance of the hive operator (and its controllers) runs on a dedicated OpenShift cluster maintained by AppSRE.
Such a cluster is known colloquially as a "shard".
Each shard is responsible for many OSD clusters, the aggregation of which represents the bulk of the OSD product at the time of this writing.

### OSD Operators
A full description of OSD is outside the scope of this document.
However, a major component is the set of SREP-owned [operators](https://visual-app-interface.devshift.net/services#/services/osd-operators/app.yml) deployed onto the hive shards and the customer clusters.
These deployments are managed by SREP-owned SaaS files which do one of two things:
- For operators deployed onto the hive shards themselves -- e.g. [aws-account-operator](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/osd-operators/cicd/saas/saas-aws-account-operator.yaml) -- [OLM CRs](https://github.com/openshift/aws-account-operator/blob/e64f7d440839959fdc030ce2f24d547d0cb0b111/hack/olm-registry/olm-artifacts-template.yaml#L45) (CatalogSource, OperatorGroup, Subscription) and any necessary supporting objects are created directly on the shard.
  Hive is not involved in this process.
- For operators deployed to customer clusters -- e.g. [must-gather-operator](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/osd-operators/cicd/saas/saas-must-gather-operator.yaml) -- OLM CRs and any necessary supporting objects are [embedded in a SelectorySyncSet](https://github.com/openshift/must-gather-operator/blob/master/hack/olm-registry/olm-artifacts-template.yaml#L17).
  Hive reconciles these SelectorSyncSets by pushing the embedded objects down into the customer clusters.
  See the [SyncSet Documentation](https://github.com/openshift/hive/blob/master/docs/syncset.md) for details.

### Environments
One shard is devoted to a single environment, but there may be multiple shards for each environment.

**Staging** environments (e.g. [hive-stage-01](https://visual-app-interface.devshift.net/clusters#/openshift/hive-stage-01/cluster.yml), [hives02ue1](https://visual-app-interface.devshift.net/clusters#/openshift/hives02ue1/cluster.yml)) are used by SREP to validate functionality and to roll out and test changes to OSD operators.

**Integration** environments (e.g. [hivei01ue1](https://visual-app-interface.devshift.net/clusters#/openshift/hivei01ue1/cluster.yml)) are used by OCM.

**Production** environments (`hivep{N}{Region}`, e.g. [hivep01ue1](https://visual-app-interface.devshift.net/clusters#/openshift/hivep01ue1/cluster.yml)) are where customer clusters are managed.

### Continuous Deployment
(TODO: diagram)

#### Build
Each merge to the `master` branch of the hive repository triggers hive's [ci-int job](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/hive/cicd/ci-int/jobs.yaml).
This [invokes](https://gitlab.cee.redhat.com/service/app-interface/-/blob/f0aeb568d87a6b219ea547c9b1d40e69ae51bfac/data/services/hive/cicd/ci-int/jobs.yaml#L27) a [script in the hive repo itself](https://github.com/openshift/hive/blob/master/hack/app_sre_build_deploy.sh) which [builds](https://github.com/openshift/hive/blob/88b1c2875b2538daac2c6765504586860601ad90/hack/app_sre_build_deploy.sh#L102) the container image for the hive operator and [pushes](https://github.com/openshift/hive/blob/88b1c2875b2538daac2c6765504586860601ad90/hack/app_sre_build_deploy.sh#L105) it to an AppSRE-owned [quay repository](https://quay.io/repository/app-sre/hive?tab=tags&tag=latest) using [credentials](https://github.com/openshift/hive/blob/88b1c2875b2538daac2c6765504586860601ad90/hack/app_sre_build_deploy.sh#L32) provided in the build environment.
These build jobs can be [monitored in Jenkins](https://ci.int.devshift.net/job/openshift-hive-gh-build-master/).

#### SaaS Deployment
Hive is redeployed to the various shards any time the (branch referenced by) `ref` for that shard changes.
Per the usual SaaS process, AppSRE applies [parameters](https://gitlab.cee.redhat.com/service/app-interface/-/blob/24b0e3f46cbb23316fc45b8ea128bb5bf837946d/data/services/hive/cicd/ci-int/saas-hive.yaml#L39-40) (including the stealth [IMAGE_DIGEST](https://github.com/openshift/hive/blob/88b1c2875b2538daac2c6765504586860601ad90/hack/app-sre/saas-template.yaml#L6814-L6815)) to a [specified](https://gitlab.cee.redhat.com/service/app-interface/-/blob/730f58cb1428a102ae4e6ade7ff5f883490fa6f1/data/services/hive/cicd/ci-int/saas-hive.yaml#L36-37) template [file from the hive repo](https://github.com/openshift/hive/blob/master/hack/app-sre/saas-template.yaml) to create a manifest; then deploys that manifest to the given shard.
These deployments, performed via tekton, can be [monitored on the app-sre-prod-01 cluster](https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.com/k8s/ns/hive-pipelines/tekton.dev~v1beta1~PipelineRun)

#### Promoting to Production
Since hive's SaaS file specifies `ref: master` for [staging and integration environments](https://gitlab.cee.redhat.com/service/app-interface/-/blob/730f58cb1428a102ae4e6ade7ff5f883490fa6f1/data/services/hive/cicd/ci-int/saas-hive.yaml#L42-69), hive is redeployed to those environments after every successful [build](#build) triggered by a merge.

[Production environments](https://gitlab.cee.redhat.com/service/app-interface/-/blob/730f58cb1428a102ae4e6ade7ff5f883490fa6f1/data/services/hive/cicd/ci-int/saas-hive.yaml#L70-87) `ref` a specific commit; so hive is only redeployed to those environments when that commit changes.
Once a week, usually on Monday, the designated [hive-cop](https://github.com/openshift/hive-sops/blob/master/sop/HiveMonitor.md) proposes a merge request to bump the commit `ref` for production environments.
The MR is created by a [script in the hive repo](https://github.com/openshift/hive-sops/blob/master/hack/promote.sh).
These MRs get the `saas-file-update` and `tenant-hive` labels, and as such may be merged via a `/lgtm` comment from any user with the [saas-hive-approver role](https://visual-app-interface.devshift.net/roles#/teams/hive/roles/saas-hive-approver.yml).

---

## Components
### HiveConfig
Hive publishes a Custom Resource Definition (CRD) for a global (non-namespaced) object of kind `HiveConfig`.
The operator expects to find exactly one instance, named `hive`; other instances are ignored.
OSD is responsible for managing the HiveConfig on each shard, defined in app-interface under resources/services/hive/$environment/hive.hiveconfig.yaml, e.g. [resources/services/hive/production/hive.hiveconfig.yaml](resources/services/hive/production/hive.hiveconfig.yaml).

A missing or corrupt HiveConfig could have various impacts depending on the scenario: anywhere from the operator refusing to deploy the controllers, down to incorrect customer cluster configuration.

### Operator Namespace and `hive-operator`
The `hive-operator` deployment in the `hive` namespace consumes the HiveConfig and in turn deploys the controllers.

If `hive-operator` is broken or missing, the controllers will not be (re)deployed.
If they are already running, they will continue to function, but any updates to HiveConfig or the deployment itself will not be picked up.

### Controller Namespace and controllers
The `hive-operator` spawns the various controllers that do the actual work.
The controllers are deployed into the namespace specified by HiveConfig.Spec.TargetNamespace, `hive` by default (same as `hive-operator`).

#### `hive-controllers` Deployment
This is the main workhorse that reconciles ClusterDeployments to provision/deprovision spoke clusters.

If `hive-controllers` is broken or missing, existing clusters will continue to function, but management operations such as provisioning, deprovisioning, and hibernate/resume will not be performed.

#### `hive-clustersync` StatefulSet
Pods created from this StatefulSet are responsible for pushing changes originating from [(Selector)SyncSets](https://github.com/openshift/hive/blob/master/docs/syncset.md) down into the spoke clusters.
Hive distributes work related to ClusterDeployments across clustersync pods by matching the ordinal of the pod name with the UID of the ClusterDeployment, modulo the number of replicas in the StatefulSet.

Hive will refuse to sync if the number of replicas does not match what is configured in the StatefulSet.
In circumstances where a replica is present but broken, its subset of ClusterDeployments will not have their (Selector)SyncSets reconciled.
This means the resources on the spoke cluster will remain in whatever state they were left in the last time that pod successfully synced; but new changes to (Selector)SyncSets will not be picked up.

#### `hiveadmission` Deployment
Hive maintains validating webhooks to block various operations that would result in invalid configurations.

If `hiveadmission` pods are missing or broken, expect CRUD operations on hive-owned CRDs to fail.

## Routes
The only explicit route hive exposes is `hive-controllers-metrics`, the endpoint from which hive exposes prometheus metrics.

## Dependencies
None.

## Service Diagram
(TODO)

## Application Success Criteria
The following assumes valid configuration of the CRs, appropriate cloud credentials, etc.
- A new ClusterDeployment is picked up and parlayed into a spoke clusters.
- Deleting a ClusterDeployment results in deprovisioning the associated spoke cluster.
- Resources in a new (Selector)SyncSet are synced to the associated spoke cluster(s), assuming they are reachable.
- Changes to resources in a (Selector)SyncSet are synced to the associated spoke cluster(s), assuming they are reachable.

## State
Hive only relies on etcd via k8s/OpenShift APIs for storage/state.

## Load Testing
A large cross-team multi-phase scale test effort was undertaken in 2020-2021. See [this doc](https://docs.google.com/document/d/1ysuCC7obdsk7NUmA4SU3zvPLU8zqhuHauNbLF2XcdsQ/edit#heading=h.z4pgsfetqk8q)

See https://github.com/openshift/hive/blob/master/docs/scaling-hive.md for general scaling considerations.

## Capacity
The OSD service limits the number of clusters per shard to [500 by default](https://gitlab.cee.redhat.com/service/uhc-clusters-service/-/blob/master/service-template.yml#L106-108) at the time of this writing.
This can be overridden per environment; for example, the [limit in staging is 800](https://gitlab.cee.redhat.com/service/app-interface/-/blob/065de76c858d0035fd8a24a13575b0131c0deb9b/data/services/ocm/cs/cicd/saas-uhc-clusters-service.yaml#L81-103) at this time.
