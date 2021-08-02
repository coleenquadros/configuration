# SOP for setting up fedramp cluster

Open MR for quota in `ocm-resources`.  [Example](https://gitlab.cee.redhat.com/service/ocm-resources/-/merge_requests/1044)

Create two AWS accounts: one for OSD, another for all other AWS resources

In app-interface AWS account:

- Create new VPC
- Create three subnets in VPC; ensure each is in unique AZ
- Create RDS subnet group
- Create security group for Elasticsearch
- Log in as root user to upgrade support plan to premium

In OSD AWS account:

- Create admin user with API credentials to be used when creating cluster in OCM

Create new cluster in OCM

- CIDR 10.150.0.0/16 and up

Set up GitHub OAuth app in RedHatInsights org

- Use info to configure github OAuth for cluster
- Grant self `dedicated-admin`

Change cluster to use fast channel:

    echo '{"version.channel_groups": "fast"}' | ocm patch -v 10 /api/clusters_mgmt/v1/clusters/1j25jirqv2k9eruqs73hlp4siihc1j13

Initiate VPC peering connection from OSD AWS account

- Make sure to enable public DNS hostnames
- Set up route tables

(optional) Add new environment to app-interface

Add OSD cluster to app-interface

- Create app-sre-bot user in dedicated-admin namespace
- `oc sa get-token app-sre-bot -n dedicated-admin`
- Copy credentials to vault.  Look at `insights/creds/kube-configs/crcgovs01ue1` as an example
- Copy e.g. `data/openshift/insights/crcgovs02ue1` folder to new cluster name
- Change all namespace refs to the correct cluster yml
- Update `cluster.yml` with relevant info; keep observability stuff blank for now

Add AWS account to app-interface

- Create `devtools-bot` admin user in IAM
- Add credentials to vault
- Copy e.g. `data/aws/insights-fedramp-stage` folder to new account name
- Change all policy refs to the correct account yml
- Update account yml with relevant info

Install observability stack on cluster

- https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-onboard-cluster.md#step-3-observability
- Can skip App SRE access steps if they are not supporting cluster

Create Elasticsearch instance

- Copy defaults file under `resources/terraform/resources/insights/.../elasticsearch-1.yml`
- Update VPC settings in cloned file
- Create new namespace under `data/services/insights/kibana/namespaces`

Install third party operators. [Example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15050)

Install Clowder.  [Example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/12966)

Install ClowdEnvironment.  [Example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15350)

For each app:

- Create new namespace file, cloned from an already-existing one
- Clone all app-specific secrets in vault
- Update cluster ref
- Update environment ref
- Update observability namespace ref
- Update aws account name
- Update app-specific vault secret refs
- (optional) Clone RDS parameter group
- create new targets for each resource template in saas-deploy file

Platform apps to deploy:

- 3scale/apicast
- entitlements
- prometheus-push
- uhc-auth-proxy
- ingress/puptoo/storage-broker
- host-inventory
- engine
- rbac
