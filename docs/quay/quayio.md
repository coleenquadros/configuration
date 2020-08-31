# [Quay.io](https://quay.io/)

## OpenShift Clusters

| Environment | Console URL |
| --- | --- |
|Stage|[Console](https://console-openshift-console.apps.quays02ue1.s6d1.p1.openshiftapps.com/)|
|Production (us-east-1)|[Console](https://console-openshift-console.apps.quayp03ue1.n7b1.p1.openshiftapps.com/)|
|Production (us-east-2)|[Console](https://console-openshift-console.apps.quayp04ue2.h5h6.p1.openshiftapps.com/)|

## Application Logs

Account ID: quayio
| Environment | Namespace |
| --- | --- |
|Stage|[CloudWatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logEventViewer:group=quay)|
|Production (us-east-1)|[CloudWatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logStream:group=osd-us-east-1/quay/app;streamFilter=typeLogStreamPrefix)|
|Production (us-east-2)|[CloudWatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logStream:group=osd-us-east-2/quay/app;streamFilter=typeLogStreamPrefix)|

## Application Metrics

| Environment | Namespace |
| --- | --- |
|Stage|[Prometheus](https://prometheus.quays02ue1.devshift.net/graph)|
|Production (us-east-1)|[Prometheus](https://prometheus.quayp03ue1.devshift.net/graph)|
|Production (us-east-2)|[Prometheus](https://prometheus.quayp04ue2.devshift.net/graph)|

## Quay Dashboards

All quay dashboards are located in the [Quay folder of our grafana server](https://grafana.app-sre.devshift.net). We currently have three dashboards:

* [Quay.io runtime](https://grafana.app-sre.devshift.net/d/_BkydJaWz/quay-io-runtime?orgId=1&refresh=1m)
* [Quay APIs](https://grafana.app-sre.devshift.net/d/JIOgB0ZGk/quay-apis?orgId=1&refresh=1m)
* [Quay AWS resources](https://grafana.app-sre.devshift.net/d/_BkydJaWqprod1234/quay-aws-resources-us-east-1?orgId=1&refresh=1m)

Each dashboard has selectors to show data from the different stage and prod environments.

## Jenkins Jobs

Quay Jenkins jobs can be found in:

* [ci-int](https://ci.int.devshift.net/view/quayio) - Deployment jobs
* [ci-ext](https://ci.ext.devshift.net/view/quayio) - PR checks and image builds

## Deployments

Deployments of quay in every namespace are done via [opensfhit-saas-deploy](/docs/app-sre/continuous-delivery-in-app-interface.md) integration. The main file controlling the deployments to the different environments is [`/data/services/quayio/saas/quayio.yaml`](data/services/quayio/saas/quayio.yaml).

* Stage deployments are triggered from the `quayio` branch. Any push to that branch will trigger a deployment to the stage enviroment(s).
* Production deployments are controlled via a hash. Any update to the hash of the different prod environments will trigger a new deployment.

Deployments in the prod environments MUST be done separately. Do NOT update the hashes of all the prod environments at the same time as it is important to verify the deployment working correctly in one environment before deploying the other.

Deployments can be managed by the development team themselves. AppSRE review or approval are not required on updates to the above saas file. A MR to the saas file will indicate the required approvers.

### Deploying Read-Only

Quay can be deployed in a read-only state, which will allow for pulls but disable all write operations. This is typically used during infrastructure migrations, such as moving the database.

See [Deploying Quay Read-Only](services/read-only.md) for more information.

### Trigger Deployment when Secret or Config has Changed

You will have to bounce all quay pods for them to load updated secrets. Since the commit hash has not changed in this scenario, you will need to update the annotation value `QUAY_APP_COMPONENT_ANNOTATIONS_VALUE`. Set this to any random string to trigger a "new" deployment.

## Managing Access for Quay Development Team

### Add User

To add a developer to Quay dev team in app-interface, create a user file in `data/teams/quay/users` directory. User schema can be found [here](../../../../app-interface/README.md#add-or-modify-a-user-accessusers-1yml). Use existing developer's user file as reference for roles and permissions.

## Updating Secret

Updating secrets for the application is three step process.
1. First you must update the secret in Vault
2. Update the reference to the secret in the namespace.
3. Trigger "new" deployment

### Updating Secret in Vault

Instructions for managing secrets in Vault can be found at [here](https://gitlab.cee.redhat.com/service/app-interface#manage-secrets-via-app-interface-openshiftnamespace-1yml-using-vault).

**When creating a new secret in Vault, be sure to set the Maximum Number of Versions field to 0 (unlimited).**

Secrets' exact location can be found in the files namespaces

| Environment | Namespace |
| --- | --- |
|Stage|https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/namespaces/quays02ue1.yml|
|Production (us-east-1)|https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/namespaces/quayp03ue1.yml|
|Production (us-east-2)|https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/namespaces/quayp04ue2.yml|

Once updated the secret, update the secret's version number to the version of secret you want on the cluster and raise a merge request for AppSRE team to review and merge.
