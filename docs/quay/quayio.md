# [Quay.io](https://quay.io/)

## OpenShift Clusters

| Environment | Console URL |
| --- | --- |
|Stage|[Console](https://console-openshift-console.apps.quayio-stage.d7r2.p1.openshiftapps.com/k8s/ns/quayio-stage/deployments)|
|Production (us-east-1)|[Console](https://console-openshift-console.apps.quayio-prod-us.k6s9.p1.openshiftapps.com/k8s/ns/quay/deployments)|
|Production (us-east-2)|[Console](https://console-openshift-console.apps.quayio-prod-us.z2r7.p1.openshiftapps.com/k8s/ns/quay/deployments)|

## Application Logs

| Environment | Namespace |
| --- | --- |
|Stage|[CloudWatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logEventViewer:group=quay)|
|Production (us-east-1)|[CloudWatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logStream:group=osd-us-east-1/quay/app;streamFilter=typeLogStreamPrefix)|
|Production (us-east-2)|[CloudWatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logStream:group=osd-us-east-2/quay/app;streamFilter=typeLogStreamPrefix)|

## Application Metrics

| Environment | Namespace |
| --- | --- |
|Stage|[Prometheus](https://prometheus.quayio-stage.devshift.net/graph)|
|Production (us-east-1)|[Prometheus](https://prometheus.quayio-prod-us-east-1.devshift.net/graph)|
|Production (us-east-2)|[Prometheus](https://prometheus.quayio-prod-us-east-2.devshift.net/graph)|


## Quay Runtime Grafana Dashboard

| Environment | Namespace |
| --- | --- |
|Stage|[Grafana](https://grafana.stage.devshift.net/d/_BkydJaWz/quay-io-runtime?orgId=1&var-rate=1m&var-datasource=quayio-stage-prometheus)|
|Production (us-east-1)|[Grafana](https://grafana.app-sre.devshift.net/d/_BkydJaWz/quay-io-runtime?orgId=1&var-rate=1m&var-datasource=quay-p-ue1-prometheus)|
|Production (us-east-2)|[Grafana](https://grafana.app-sre.devshift.net/d/_BkydJaWz/quay-io-runtime?orgId=1&var-rate=1m&var-datasource=quayio-prod-us-east-2-prometheus)|

## Quay AWS Resources Grafana Dashboard

| Environment | Namespace |
| --- | --- |
|Stage|[Grafana](https://grafana.stage.devshift.net/d/_BkydJaW123/quay-stage-aws-resources-us-east-1?orgId=1&refresh=1m)|
|Production (us-east-1)|[Grafana](https://grafana.app-sre.devshift.net/d/_BkydJaWqprod1234/quay-production-aws-resources-us-east-1?orgId=1&refresh=1m)|
|Production (us-east-2)|N/A|

## Jenkins Jobs

Quay Jenkins jobs can be found [here](https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/quayio/). Following Jenkins configured for Quay right now:

1. [[quayio] build master and deploy to stage](https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/quayio/job/quay-quay-gh-build-master/) - This job is triggered every time a pull request is merged to quay repository's master branch. It will build container image and deploy latest code to `stage` cluster.
2. [[quayio] saas pr check quayio-prod-us-east-1](https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/quayio/job/service-saas-quay-quay-saas-pr-check-quayio-prod-us-east-1/) - This job is triggered every time a merge request is raised on `saas-quay` repository. It will validate the environment variables for `quayio-prod-us-east-1` cluster provided in saas-quay repository against the Quay OpenShift template.
1. [[quayio] saas pr check quayio-prod-us-east-2](https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/quayio/job/service-saas-quay-quay-saas-pr-check-quayio-prod-us-east-2/) - This job is triggered every time a merge request is raised on `saas-quay` repository. It will validate the environment variables for `quayio-prod-us-east-2` cluster provided in saas-quay repository against the Quay OpenShift template.
1. [[quayio] saas deploy quayio-prod-us-east-1](https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/quayio/job/service-saas-quay-quay-saas-deploy/) - This job is triggered when merged request is merged. It will deploy to the `us-east-1` cluster.
1. [[quayio] saas deploy quayio-prod-us-east-2](https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/view/quayio/job/service-saas-quay-quay-saas-deploy-with-upstream-service-saas-quay-quay-saas-deploy-quayio-prod-us-east-2/) - This job is triggered when deployment to `us-east-1` cluster is successful.

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

| Environment | Vault URL |
| --- | --- |
|Stage|https://vault.devshift.net/ui/vault/secrets/app-interface/list/quayio-stage/quayio-stage/|
|Production (us-east-1)|https://vault.devshift.net/ui/vault/secrets/app-interface/list/quayio-prod-us-east-1/quay/|
|Production (us-east-2)|https://vault.devshift.net/ui/vault/secrets/app-interface/list/quayio-prod-us-east-2/quay/|

### Update Secret Reference

Update the secret's version number to the version of secret you want on the cluster and raise a merge request for AppSRE team to review and merge.

| Environment | Namespace |
| --- | --- |
|Stage|https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/namespaces/quayio-stage.yml|
|Production (us-east-1)|https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/namespaces/quayio-prod-us-east-1.yml|
|Production (us-east-2)|https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/namespaces/quayio-prod-us-east-2.yml|

## Production Deployment

Production deployments will happen from the `master` branch of the Quay repository. You will need the full hash of the commit you want to promote to production. The deployment pipeline is setup to perform a zero downtime rolling update on the clusters. Deployment pipeline will deploy to one cluster at a time starting with `us-east-1`. Successful deployment will trigger the deployment pipeline for the cluster in `us-east-2` region. Deployment to the cluster in  `us-east-1` region takes about 12-15 minutes.

Access to the [saas-quay](https://gitlab.cee.redhat.com/service/saas-quay) repository is managed by GitLab group [quay-dev](https://gitlab.cee.redhat.com/quay-dev).

Deployments are managed by the development team themselves. AppSRE review or approval are not needed on merge requests to the [saas-quay](https://gitlab.cee.redhat.com/service/saas-quay).

### Deploying Read-Only

Quay can be deployed in a read-only state, which will allow for pulls but disable all write operations. This is typically used during infrastructure migrations, such as moving the database.

See [Deploying Quay Read-Only](services/read-only.md) for more information.

### Trigger Deployment on Code Change
To promote changes to production, you need to update the commit hash in the [saas-quay](https://gitlab.cee.redhat.com/service/saas-quay) repository. Once you have raised a merge request, you need to work with Quay developers who have permission to merge. Once the merge request is merged, deployment pipeline will be automatically triggered to perform new deployment. Here's an [example](https://gitlab.cee.redhat.com/service/saas-quay/merge_requests/25/diffs).

### Trigger Deployment when Secret or Config has Changed

You will have to bounce all quay pods for them to load updated secrets. Since the commit hash has not changed in this scenario, you will need to update the annotation value `QUAY_APP_COMPONENT_ANNOTATIONS_VALUE`. Set this to any random string to trigger a "new" deployment. See [example](https://gitlab.cee.redhat.com/service/saas-quay/merge_requests/29/diffs) merge request.

