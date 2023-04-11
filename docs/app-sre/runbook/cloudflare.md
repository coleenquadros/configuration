# Cloudflare

[TOC]

## Overview

AppSRE enables users to provision Cloudflare resources as part of their service architecture

The currently supported Cloudflare services are:
- Zones (records)
- Argo
- Workers (routes, scripts)

We support any account tier (Free, Business, Enterprise) but certain resources or parameters requires higher tier accounts to be enabled. Refer to Cloudflare's [account plans overview](https://www.cloudflare.com/en-ca/plans/#overview) or the [cloudflare terraform module docs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs) for more details

## Architecture

### Accounts

Cloudflare accounts are defined in app-interface using the `/cloudflare/account.yml` schema

Cloudflare resources are defined per namespaces via [externalResources definitions](https://gitlab.cee.redhat.com/service/app-interface#manage-external-resources-via-app-interface-openshiftnamespace-1yml)

Information regarding the supported resources and their schemas can be found in the [graphql definitions in qontract-schemas](https://github.com/app-sre/qontract-schemas/blob/main/graphql-schemas/schema.yml)

Additional information on specific resource parameters can be found in the [cloudflare terraform module docs](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)

## Metrics and Dashboards

* [Cloudflare Analytics dashboard in grafana](https://grafana.app-sre.devshift.net/d/mWxtnz5Mz/cloudflare-zone-analytics?orgId=1&var-datasource=app-sre-prod-01-prometheus&var-zone=quay.io&from=now-3h&to=now)

We use the [lablabs/cloudflare-exporter](https://github.com/lablabs/cloudflare-exporter) to export metrics from Cloudflaire Analytics into prometheus. Currently, we maintain a [fork](https://github.com/lablabs/cloudflare-exporter) to address the lack of Logpush metrics on the upstream. The work was completed through [APPSRE-7293](https://issues.redhat.com/browse/APPSRE-7293)

## Troubleshooting

### terraform-cloudflare-dns integration

#### Zone manually deleted

The error message below may indicate that a Cloudflare DNS zone was manually deleted. This can be verified by checking the Cloudflare audit log and searching for the zone in question.

```
[terraform-cloudflare-dns] error: b'\nError: error finding Zone "0f17ee691c67ac7df9cfc56db9f92372": Invalid zone identifier (1001)\n\n\n'
```

Reach out to the owners of the zone to figure out if this was in fact deleted manually. If it was, advise the tenants to add `delete: true` to the `/cloudflare/dns-zone-1.yml` file in the future. To stop the errors, the `/cloudflare/dns-zone-1.yml` file can be removed so that the integration will no longer run against that shard.

### terraform-cloudflare-users integration

#### Integration unable to create cloudflare account member
Sometimes `terraform-cloudflare-users` integration fails with the following error:

```
error creating Cloudflare account member: Error when processing member: cannot add existing user that is participating in an incompatible authorization system (1005)
```
Per Cloudflare support team this happens because:

```
Users with Domain Scoped Roles enabled can ONLY manage other members also enrolled with Domain Scoped Roles.
Users without Domain Scoped Roles enabled can NOT manage users with Domain Scoped Roles enabled.
```

If we run into this issue, we need to do the following
1. Remove user access temporarily by unsetting `cloudflare_user` field within `/access/user-1.yml` and notify the user.
1. Reach out to Cloudflare support through a ticket mentioning this issue.
1. Once Cloudflare support fixes the issue in their backend, set `cloudflare_user` field and verify integration succeeds.

### Dashboard access

[Cloudflare Dashboard](https://dash.cloudflare.com/)

Credentials to Cloudflare accounts can be found in [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/cloudflare). The table below describes which user has access to which account.

| User email                               | Accounts                             |
|------------------------------------------|--------------------------------------|
| sd-app-sre+cloudflare-app-sre@redhat.com | app-sre<br/>quay-stage<br/>quay-prod |


The 2FA TOTP codes for each account can be retrieved from Vault. The exact path to query is defined under the `2fa_code` key under each account (DO NOT use the recovery codes, except under an emergency situation)

Example
```sh
vault login -method=oidc -address=https://vault.devshift.net
vault read totp/app-sre/code/sd-app-sre+cloudflare-app-sre
```

### Enterprise support

**Non-critical production issues**
* For reactive and immediate responses: Open a support ticket via the Cloudflare Dashboard under the Support / Contact Support menu
* Email 24/7 Enterprise support team at entsupport@cloudflare.com
  * Support team will review emails only from registered account users
* Web chat via the Cloudflare Dashboard

**24/7 Emergency line**
* North America: +1 (650) 353-5922
* UK: +44 808-169-9540
* Singapore: +65 800-321-1182
* Additional info can be found at the [Enterprise Customer Portal](https://cloudflare.com/ecp/overview/) (need to be logged in to the account)

Security verification is mandatory to receive enterprise support. Such verification is done via a `Single-use token` which can be retrieved via the Cloudflare dashboard, under Contact Support / Get Single-use token

## SOPs

### Creating a new Cloudflare account

Cloudflare doesn't support email sub-addressing, so we cannot have a unique user login per account. Follow the steps below only if there isn't already a system account setup that would be appropriate for this use case.

- Go to https://dash.cloudflare.com/sign-up
- Enter desired user & password
  - Email: appropriate team address, again sub-addressing isn't supported
  - Password: generate something secure
- Complete email verification
- Enable 2FA
  - Login to the account
  - Go to "My Profile"
  - Go to "Authentication"
  - Click "Enable 2FA"
  - [Add the 2FA to vault](https://gitlab.cee.redhat.com/service/app-interface#manage-vault-secret-engines-vault-configsecret-engine-1yml)

The steps below are followed for new accounts whether there is an existing user login or not:

- Invite the system account user
  - This will generally be done by the Cloudflare team, just provide them with the email that you'd like to use
- Create an API Token for use by the integration
  - Login to the account
  - Go to "My Profile"
  - Go to "API Tokens"
  - Click "Create Token"
  - Set up the token with the following permissions:
    - Account: Account Settings: Edit
    - Account: Billing: Edit
    - Account: Worker Scripts: Edit
    - Account: Logs: Edit
    - Zone: Zone: Edit
    - Zone: SSL and Certificates: Edit
    - Zone: Zone Settings: Edit
    - Zone: Workers Routes: Edit
    - Zone: DNS: Edit
    - Zone: Logs: Edit

### Enable Cache Reserve on Cloudflare zone

Cache Reserve is a beta product that the Cloudflare terraform provider do not support yet. The quay.io is using that product to further reduce egress cost with S3 through extended cache persistence via Cache Reserve at the Cloudflare edge.

https://developers.cloudflare.com/cache/about/cache-reserve/

https://issues.redhat.com/browse/APPSRE-7225

Initial support for Cloudflare Cache Reserve was added to the cloudflare zone schemas but has not been automated as part of the integration as the integration is tightly coupled with the ExternalResourceSpec pattern and terrascrip;t/terraform. As such for now we need to manually enable/disable Cache Reserve as needed.

1. Validate that the `cache_reserve` setting has been added to the Cloudflare zone in app-interface. As this is a manual change, this step is important to ease the migration/import in the future when this is automated. Note the Cloudflare account, zone name and setting value (`on`/`off`)
1. Ensure you have [configured your cloudflare user](https://gitlab.cee.redhat.com/service/app-interface#manage-cloudflare-user-access-via-app-interface-using-terraform)
1. Login to Cloudflare
1. Access the account for which you want to make a change
1. Select the Cloudflare zone for which you want to configure Cache Reserve
1. In the left side menu, expand `Caching` and select `Cache Reserve (beta)`
1. Click `Enable Storage Sync` or `Disable Storage Sync`

**Note:** If the `Cache Reserve (beta)` menu item does not show up or if the option is grayed, it is likely that the feature is not enabled for the Zone or the Account

### Import a Cloudflare Zone

Importing a Cloudflare zone is not much different than importing other kinds of terraform resources

1. Preparation
    1. Dump the terraform config for the specific account (to make things faster)
        ```sh
        qontract-reconcile ... terraform-cloudflare-resources --account-name <acct_name> --print-to-file /tmp/cftf/config.tf.json
        ```
    1. Remove the comment at the top of the json config file
    1. Initialize the terraform state and check the plan (it should state it wants to create the zone)
        ```sh
        terraform init
        terraform plan
        ```
    1. Disable the terraform-cloudflare-resources integration via Unleash
1. Gather information
    1. Find out what the Zone ID is
        ```sh
        curl -sX GET "https://api.cloudflare.com/client/v4/zones" \
            -H "Authorization: Bearer <api_token>" \
            -H "Content-Type: application/json" | jq .
        ```
    1. Find out what zone settings have been overridden
        ```sh
        curl -sX GET "https://api.cloudflare.com/client/v4/zones/<zone_id>/settings" \
            -H "Authorization: Bearer <api_token>" \
            -H "Content-Type: application/json" | jq '.result[] | select(.modified_on != null)'
        ```
    1. Ensure the overridden settings are added to the zone definition under `settings`
      a. If zone settings were updated, re-generate the terraform config from step 1 and then continue
1. Importing
    1. Import the resource in terraform (zone settings cannot be imported hence why we manually checked and set them previously)
        ```sh
        terraform import cloudflare_zone.<resource_name> <zone_id>
        ```
1. Finalizing
    1. Run terraform plan and the integration in --dry-run, both should normally be NO-OP
        ```sh
        terraform plan

        qontract-reconcile ... terraform-cloudflare-resources --dry-run
        ```
    1. Open a MR to add the resources you imported
    2. Merge the MR
    3. Re-enable the integration
    4. The next integration run should be a NO-OP

### Import a Cloudflare Record

**Note:** Not all records may be managed by the integration.

In some cases it may be desirable to only partially manage DNS records in Cloudflare Some examples:

- Importing a legacy zone
- Lots of records (some managed by the integration, rest manually) as a workaround to performance limitations of Terraform

1. Follow the `Premaration` steps from `Importing a Cloudflare Zone`
1. Gather information
    1. To find what the record ID is for the record we want to import
        ```
        curl -sX GET "https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records" \
            -H "Authorization: Bearer <api_token>" \
            -H "Content-Type: application/json" | jq .
        ```
1. Import
    1. Import the record into terraform
        ```
        terraform import cloudflare_record.<resource_name> <zone_id>/<record_ID>
        ```
1. Follow the `Finalizing` steps from `Importing a Cloudflare Zone`

### Increase Cloudflare Quotas

#### API rate limit

The Cloudflare API has a rate limit of 1200 requests per 5 minutes as documented [here](https://developers.cloudflare.com/fundamentals/api/reference/limits/). The API rate limit is set on a per-user basis.

The process to have the rate limit raised is to open a support ticket and copy Tim Flynn and Brian Ceppi on it

#### App Interface Specific Maxium record count per Cloudflare DNS zone

For performance consideration, we limit each zone to 500 records by default. This number can be raised by setting an overwrite using the zone's `max_items` field. This number should not be raised higher than 1500 and raising it always requires APP SRE's approval. When considering the request, please keep in mind that every addition of 1000 records, it adds around 5 minutes run time to MR checks for any qontract promotions, and anything could trigger terraform-cloudflare-dns integration.

#### Cloudflare Maximum record count per zone

The maximum number of records per zone for Free accounts is 1000. The limit is 3500 for Enterprise accounts.

This is set on a per-zone basis, so a requirement to have this limit increased is to have the zone already created

The process to have the record limit increased is to open a support ticket and copy Tim Flynn and Brian Ceppi on it

## Helpful links & resources

[Cloudflare status page](https://www.cloudflarestatus.com/)

Enterprise account contacts:

| Name           | Email                   | Role                        |
|----------------|-------------------------|-----------------------------|
| Tim Flynn      | tflinn@cloudflare.com   | Customer Success Manager    |
| Tom Hammell    | thammell@cloudflare.com | Field Solutions Engineer    |
| Brian Ceppi    | bceppi@cloudflare.com   | Enterprise Account Manager  |
| Rick Fernandez |                         | Customer Solutions Engineer |

# Service specific notes

## Quay.io

### Traffic routing

Not all repositories may be routed through Cloudflare. We use the AWS Application Load-Balancer rules to determine what quay service & pods traffic is routed to for a given URI, which includes organisations and repository names allowing us to route on per org, per repository (ex: `https://quay.io/v2/some-org/some/repo/*`). These rules are defined under the ALB provider in the quay namespace definition file.

One way to determine whether traffic for a given repository is routed through cloudflare is to look at response headers:

```sh
# Repo to test
REPO=quayio-cloudflare-test/busybox

# Grab the blobs for a given image
$ curl -sL https://quay.io/v2/$REPO/manifests/latest | jq -r '.fsLayers[].blobSum'
sha256:ee780d08a5b4de5192a526d422987f451d9a065e6da42aefe8c3b20023a250c7
sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4
sha256:9c075fe2c773108d2fe2c18ea170548b0ee30ef4e5e072d746e3f934e788b734

# Retrieve one of the blobs, show headers and output the redirect location (quay redirects to the CDN url)
$ curl -vLo /dev/null -w '%{url_effective}' https://quay.io/v2/$REPO/blobs/$BLOB
[...a bunch of connection info and headers...] 
https://cdnXX.quay.io/sha256/9c/... (long url that includes AWS parameters as well as a cf_sign and cf_expiry parameters)

# cdn01 & cdn02 are CloudFront
# cdn03 is Cloudflare

# Additionally, Cloudflare headers starts with cf- so that is also an indication that the request went through Cloudflare
# < cf-ray: 768027d679740595-IAD
# < cf-cache-status: HIT
```

## Known Issues:
### Records still present after zone removed
  When a zone is deleted then added back, the old records are still present. Integration will have following errors:
```
[2023-03-22 19:25:33] [ERROR] [terraform_client.py:check_output:571] - [redhat-service-delivery-openshift-com - apply] Error: expected DNS record to not already be present but already exists
[2023-03-22 19:25:33] [ERROR] [terraform_client.py:check_output:571] - [redhat-service-delivery-openshift-com - apply]   on config.tf.json line 14651, in resource.cloudflare_record.cname-metrics-gchaturv-test-openshift-com:
[2023-03-22 19:25:33] [ERROR] [terraform_client.py:check_output:571] - [redhat-service-delivery-openshift-com - apply] 14651:       },
```
Solution: When deleting zone, use the `delete: true` flag on the zone file. See the Delete Cloudflare resource section in App Interface Readme.
