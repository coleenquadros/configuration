# Guidelines to determine which cluster to use during new tenant onboarding

The objective of this document is to help AppSRE member to determine which cluster to use for new tenant service. This step should be done at the early stages of onboarding when we discuss onboarding questionnaire and before we start with self-service stage for the tenant.

## Guidelines

- We try to put most services under `api.openshift.com` or under `console.redhat.com`.
    * if a service is a component under api.openshift.com, it should be deployed in `app-sre-stage-01` and `app-sre-prod-04`.
    * if a service is a component under console.redhat.com, it should be deployed in `crcs02ue1` and `crcp01ue1`.
- If a service needs to use Tekton CRDs, it should be deployed in `app-sre-stage-01` and `app-sre-prod-01`.
- Services that require dedicated resources will have their own clusters. For e.g telemeter and quay.io have their own dedicated clusters.
- If service is being put under an existing cluster, we need to ensure it can satisfy the resource requirements by verifying the existing capacity at [https://grafana.app-sre.devshift.net/d/k8s-compute-resources-cluster/kubernetes-compute-resources-cluster](https://grafana.app-sre.devshift.net/d/k8s-compute-resources-cluster/kubernetes-compute-resources-cluster).
    * If a cluster determined through above guidelines is unable to satisfy resource capacity request (not applicable in case of dedicated cluster), then we may have to scale the cluster or create a new cluster. This will require further discussion with the appropriate stakeholders.
