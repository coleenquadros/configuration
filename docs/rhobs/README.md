# Setting up a new RHOBS cluster
All RHOBS clusters exist under `data/services/rhobs/observatorium-mst` (MST - which stands for managed services tenant - is a legacy name that we keep using for now).

Namespaces are structured based on the clusters. For each new cluster, create a new subdirectory in `data/services/rhobs/observatorium-mst/namespaces/<new_cluster_name>`. This directory will include all new namespace SaaS files.

New cluster namespaces are then goverend by the CICD files in `data/services/rhobs/observatorium-mst/cicd`. You would need to add the namespaces to the appropriate CICD files, in line with the instructions below.

_Please beware that most of the changes below cannot be self-serviced, i.e. they require an approval from the AppSRE. Although generally this process is fast, the extra time required for reviews by people outside of our team should be taken into consideration when planning cluster creation._

## Provisioning a new RHOBS cluster
A new cluster is usually provisioned in copperation with AppSRE. With currently have 2 clusters both in `us-east-1`:
- `data/openshift/telemeter-prod-01/cluster.yml`
- `data/openshift/rhobsp02ue1/cluster.yml`

When creating a new cluster, prefer memory-optimized instances, e.g. for cluster `rhobsp02ue1` we use `r5.8xlarge`. This all depends on the requirements for the new cluster and managerial approval.

## Creating resources
- For new cluster's role and role binding, you can reuse `resources/app-sre/observatorium-mst-production/observatorium-mst.clusterrole.yml` and `resources/app-sre/observatorium-mst-production/observatorium-mst.serviceaccount.yaml`
- For the tools namespace, you can reuse `resources/app-sre/observatorium-mst-production/observatorium-tools.clusterrole.yml` and `resources/app-sre/observatorium-mst-production/observatorium-tools.serviceaccount.yaml`
- When creating new routes, follow the `<service>.<cluster_name>.api.openshift.com` pattern. For example, for Alertmanager on cluster `rhobsp02ue`, this would be `alertmanager.rhobsp02ue1.api.openshift.com`

## Requesting creation of DNS entries
To create functioning routes, adding route resources from previous step is not enough. Proper DNS entries for the cluster need to be created. This is done by creating a request to the OpenShift Hosted SRE Support.

To request this, open a JIRA ticket in the OHSS project. You can follow [this](https://issues.redhat.com/browse/OHSS-14411) ticket to create ticket for DNS entries in the new cluster. Don't forget to specify that these entries need to have CNAME type.

_Since this change is done manually and it can take a couple of days to be processed, it is recommended to open the ticket as soon as possible_

## Creating S3 resources
Create a new S3 resources (bucket) for the new cluster. We need two buckets - one for metrics and one for rules. Add them to `externalResources` in the new `observatorium-mst-production` namespace file, follow configuration from existing clusters.

## Adding CloudWatch access
Make sure you add the new cluster to `data/services/observability/namespaces/app-sre-observability-production.yml` to the external resources to enable CloudWatch access.

## Proxy secrets
Make sure to include secrets to generate cookie secret for oauth-proxy sidecars. These can be reused from other clusters. See `data/services/rhobs/observatorium-mst/namespaces/rhobsp02ue1/observatorium-mst-production.yml` for reference - new cluster should have all `vault-secret`s with suffix `*-proxy` added.

## Creating namespaces
Follow the established pattern: New namespaces should be created under `data/services/rhobs/observatorium-mst/namespaces/<cluster_name>`.

When creating new namespaces, reuse / follow the following pattern:
- Create a `observatorium-mst-production` namespace. This namespace shall contain both `observatorium-common` and `observatorium-metrics` templates.
- Create a `observatorium-tools` namespace. This namespace shall contain Jaeger and Parca templates.

Follow the example of `data/services/rhobs/observatorium-mst/namespaces/rhobsp02ue1` and create files for:
- `observatorium-mst-cluster-scope-production.yml`
- `observatorium-mst-production.yml`
- `observatorium-tools-cluster-scope-production.yml`
- `observatorium-tools-production.yml`

## Adding namespaces to non-RHOBS related roles
For proper functioning within AppSRE, the newly created `observatorium-mst-production` namespace should be added to following roles:
- `data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml`
- `data/teams/rhobs/roles/observatorium-bot.yml`
- `data/teams/telemeter/roles/dev.yml`

[Example PR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/43988)

## Creating S3 resources
Create a new S3 resources (bucket) for the new cluster. We need two buckets - one for metrics and one for rules. Add them to `externalResources` in the new `observatorium-mst-production` namespace file, follow configuration from existing clusters.

## Adding CloudWatch access
Make sure you add the new cluster to `data/services/observability/namespaces/app-sre-observability-production.yml` to the external resources to enable CloudWatch access.

## Proxy secrets
Make sure to include secrets to generate cookie secret for oauth-proxy sidecars. These can be reused from other clusters. See `data/services/rhobs/observatorium-mst/namespaces/rhobsp02ue1/observatorium-mst-production.yml` for reference - new cluster should have all `vault-secret`s with suffix `*-proxy` added.

## Deploying templates
Add entries into appropriate Saas files for the new namespaces:
- For monitoring, add `observatorium-mst-production` namespace into `data/services/rhobs/observatorium-mst/cicd/saas-monitoring.yaml`. This will enable monitoring and will only manage `ServiceMonitor` resources.
- For metrics and Observatorium templates, add `observatorium-mst-production` namespace into `data/services/rhobs/observatorium-mst/cicd/saas.yaml` under both resource templates: `observatorium-mst-common` and `observatorium-mst-metrics`. Copy and adjust parameters from the existing clusters.
- For tools, add `observatorium-tools-production` namespace into `data/services/rhobs/observatorium-mst/cicd/saas-tools.yaml` into Jaeger and Paraca resource templates.
- Don't forget to add `observatorium-tools-production` namespace to `networkPoliciesAllow:` section of `observatorium-mst-production` namespace to allow communication between namespaces.

## Configuring tenants
To configure tenants, adjust the `data/services/rhobs/observatorium-mst/cicd/saas-tenants.yaml` file. You'll need to add a new `- namespace:` entry in the list and configure the tenants appropriately. You can follow existing tenants config from other clusters as a reference.

For now, because we do not have regionally aware SSO, it is fine to reuse the same client ID / secret and tenant service accounts on all clusters.

Don't forget to appropriately set `redirectURL` and also to create IT services ticket to _append_ new redirect URLs to the main service account (follow sections `Template Service Account Request Text`, but in this case we only the request to `Append one new allowed callback URL to the list of allowed callback URLs...`). This is to ensure that accessing UI via browser works.

## Setting up Grafana and alerting rules
If you have monitoring template set up, you can add the cluster as a data source to the AppSRE Grafana. You can achieve this by adding it to the `data/services/observability/shared-resources/grafana.yml`. To find the `slug` parameter, consult the cluster YAML file.

To enable alerting, you should add the cluster-specific alerting rules under `data/services/observability/namespaces/openshift-customer-monitoring.<new_cluster_name>.yml`. Currently there are three main rule files you'd want to use:
- Tenants alerting -> `/observability/prometheusrules/observatorium-tenants-production.prometheusrules.yaml`
- Thanos infrastructure alerting -> `/observability/prometheusrules/observatorium-thanos-production.prometheusrules.yaml`
- HTTP traffic -> `/observability/prometheusrules/observatorium-http-traffic-production.prometheusrules.yaml`

In addition, don't forget to add the closed-box monitoring for the API route. You can do this by adding an entry in `data/services/rhobs/observatorium-mst/app.yml` under `endPoints` (follow example from other clusters).
