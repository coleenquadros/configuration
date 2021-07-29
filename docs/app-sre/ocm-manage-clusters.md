# Managing OSDv4 clusters with OCM

OSDv4 clusters are managed via OCM.

- Production: https://cloud.redhat.com/openshift
- Staging: https://qaprodauth.cloud.redhat.com/openshift

## Creating an Account

All AppSRE OSDv4 clusters are created in the `sd-app-sre <sd-app-sre@redhat.com>` organization.

Each AppSRE member will need to have an account in that organization in order to be able to view and managed the clusters within that organization. All the accounts must be marked as "Organization Administrator" (Access Permissions - Account Roles).

Accounts must be created by other team members who are already in that organization. This is done via this portal:
https://www.redhat.com/wapps/ugc/protected/usermgt/userList.html

The agreement is that all accounts will have a login with this pattern: `<username>+sd-app-sre`. The Email address will be set to `<username>+sd-app-sre@redhat.com`.

All users should be admins in the `sd-app-sre` organization.

## Quotas

We can only deploy as many clusters as our quotas allow us.

Quotas are managed via the [ocm-resources](https://gitlab.cee.redhat.com/service/ocm-resources/) repository.

- The sd-app-sre organization ID is: 12147054
- The internal OCM ID for the sd-app-sre organization (production) is: 1OXqyqko0vmxpV9dmXe9oFypJIw
- The internal OCM ID for the sd-app-sre organization (staging) is: 1QxuZ9DyDkGuTuijEXoncha6QTq

As of 2020-01-30 the quota files in the ocm-resources repo are:

- [uhc-production/orgs/12147054.yaml](https://gitlab.cee.redhat.com/service/ocm-resources/blob/master/data/uhc-production/orgs/12147054.yaml)
- [uhc-stage/orgs/12147054.yaml](https://gitlab.cee.redhat.com/service/ocm-resources/blob/master/data/uhc-stage/orgs/12147054.yaml)

In order to request more quota, a PR must be sent to those files requesting more SKUs. This request must be approved by Aaron Weitekamp, as well as Jonathan Beakley from the AppSRE side.

For more information look at [How to request quota for creating OpenShift Dedicated cluster](https://mojo.redhat.com/docs/DOC-1199606). Note that as AppSRE is part of SD, we do not need to create a PO.

## OCM CLI

OCM provides a CLI. It's a binary file that can be executed directly:
https://github.com/openshift-online/ocm-cli

In order to login the a token must be obtained from https://console.redhat.com/openshift/token.

Example:

```
$ ocm login --token $OCM_TOKEN
$ ocm whoami
{
  "kind": "Account",
  "id": "1Umiv1beZL0fGRPgDdnkrUxHIr4",
  "href": "/api/accounts_mgmt/v1/accounts/1Umiv1beZL0fGRPgDdnkrUxHIr4",
  "email": "jmelis+sd-app-sre@redhat.com",
  "first_name": "jaime",
  "last_name": "melis",
  "organization": {
    "kind": "Organization",
    "id": "1OXqyqko0vmxpV9dmXe9oFypJIw",
    "href": "/api/accounts_mgmt/v1/organizations/1OXqyqko0vmxpV9dmXe9oFypJIw",
    "external_id": "12147054",
    "name": "Red Hat"
  },
  "username": "jmelis+sd-app-sre"
}
```

Similarly, to login to staging, the following command must be used: `ocm login --url staging --token $OCM_TOKEN`

## OCM cli tips

List SKUs:

```
ocm get /api/accounts_mgmt/v1/skus
```

List Addons:

```
ocm get /api/clusters_mgmt/v1/addons
```

Find Cluster ID:

```
ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '$CLUSTER_NAME'" | jq -r .items[].id
```

Find the Expiration Time:

```
ocm get cluster $CLUSTER_ID | jq -r .expiration_timestamp
```

Extend **staging** Clusters lifetime (note: we need Narayanan's and Jonathan Beakley's approval for this):

```
# login into *staging*
ocm patch /api/clusters_mgmt/v1/clusters/CLUSTER_ID << EOF
> {
>   "expiration_timestamp": "$(date -v +7d +"%Y-%m-%dT%TZ")"
> }
> EOF
```

NOTE: The format for the expiration_timestamp is YYYY-MM-DDTHH:MM:SSZ, for example 2021-01-29T14:02:36Z

TIP: Instead of using `date -v +7d +"%Y-%m-%dT%TZ"` to generate the date, some date implementations support a `--iso-8601=seconds` option which can be used instead.  The output of this command may be rejected by OCM which is why this is left as an alternate means to generate the timestamp.  To use this, substitute `date -v +7d +"%Y-%m-%dT%TZ"` with `--iso-8601=seconds -d '+7 days'` in the `ocm patch` command above.

Obtain `cluster-admin` for a **staging** cluster (note: your user needs the SREP role in ocm-resources: [example](https://gitlab.cee.redhat.com/service/ocm-resources/merge_requests/102)):

```
ocm /get/api/clusters_mgmt/v1/clusters/<your-cluster-id-here>/credentials
```

More info: https://api.openshift.com

## OCM cluster creation and query

The AppSRE team can create clusters in the staging environment when you login:  
`--url staging` and UI for stage is https://qaprodauth.cloud.redhat.com/openshift/  


### Creating a cluster

First make sure you have enough quota to create a cluster
```
ocm account quota
```
__Output:__
```
Cluster quota for organization 'Red Hat - Service Delivery - AppSRE' ID: '1QxuZ9DyDkGuTuijEXoncha6QTq'
0/100 dbaOperatorAddon ANY
1/2 m5.2xlarge SINGLE
0/1 m5.xlarge MULTI
1/1 m5.xlarge SINGLE
```
In the example above I still have quota to create a cluster in multizone

```
ocm create cluster --version openshift-v4.6.1 --multi-az mytestcluster
```

### Querying an existing cluster
```
ocm get /api/clusters_mgmt/v1/clusters --parameter search="name like '<full name of cluster>'"
```
