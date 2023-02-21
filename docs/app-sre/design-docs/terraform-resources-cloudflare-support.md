# Design doc: Cloudflare support in qontract-reconcile

## Author/date

steahan / June 28, 2022

* Updated January 2023 to cover Cloudflare ACM certificate renewal

## Tracking JIRA

https://issues.redhat.com/browse/SDE-1958

## Problem Statement

Quay.io spends
a [significant amount of money](https://docs.google.com/spreadsheets/d/1wT9BEyiVFrXWDTAy4K-Ldbhbgc8i4w6wKeHmoZsLxcY/edit#gid=0)
on AWS CloudFront each month for caching container images. The Quay team has created a
proposal to switch
to [Cloudflare as a CDN provider](https://docs.google.com/document/d/1B1wS4aMEF1Y4uIpXHRZHXKm7Ff9Fq_rwBWXyLGZlpDA/edit)
as it would provide significant cost savings.

## Goals

* Support a subset of Cloudflare provider resources that are specific to the Quay use
  case. The known resources are:
    * `cloudflare_zone` - controls the high-level domain configurations
    * `cloudflare_zone_settings_override` - overrides zone defaults for many settings
      related to TLS, caching, and many other settings
    * `cloudflare_record` - DNS records that are required for “proxy” mode
    * `cloudflare_worker_route` - links Cloudflare Workers to a specific route
    * `cloudflare_worker_script` - deploys the Cloudflare Workers code
    * `cloudflare_argo` - Argo controls tiered caching and smart routing
    * `cloudflare_certificate_pack` - provision Advanced Certificate Manager (ACM)
      certificates for edge TLS
* Establish a pattern for supporting >1 Cloud provider with Terraform
* Implement the solution in the next 2-3 months

## Non-objectives

* Significant refactoring or upgrades of the existing terraform-resources integration,
  or related components, for any reason other than to enable Cloudflare
    * This may be a worthwhile initiative, but it needs to be a separate initiative
    * This also includes removing dependencies on Terraform < 1.0 and removing the
      dependency on Terrascript altogether
    * **This doesn’t include new code, as stated later in the document, we should try to
      avoid some of the problems in the existing code when writing new components**
* Any resources not explicitly listed in the Goals section
* User management (managing tenant access to the Cloudflare console) is out of scope for
  the initial phase
* Any production readiness tasks will need to be completed, but those are not in the
  scope of this document
    * Monitoring/metrics
    * Documentation/SOPs beside the integration’s own documentation

## Proposal

### Cloudflare Terraform Provider

[Cloudflare has a Terraform provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
that can be used to provision Cloudflare resources. This means that we can treat
Cloudflare resources much like we do AWS resources. There are two issues that we’re up
against related to the Cloudflare Terraform Provider:

1. The version being actively developed (3.x) has dropped support
   for [Terraform 0.13 and older](https://registry.terraform.io/providers/cloudflare/cloudflare/3.0.0/docs/guides/version-3-upgrade#terraform-013-and-older-versions-no-longer-supported)
   . qontract-reconcile currently uses Terraform 0.13, so if we run into any issues, we
   cannot expect them to be addressed by Cloudflare.
2. Version 2.x supports Terraform 0.13, but Cloudflare has documented
   that [additional 2.x releases are not expected](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/guides/version-3-upgrade#provider-version-configuration)
   , meaning that provider is unsupported.

While we’d like to avoid significant refactoring as part of the support for Cloudflare,
it should be clear that the **trade-off that we’re making is that either of the options
above will leave us in an unsupported state**. This could mean that we may lock
ourselves into using the existing versions where we cannot upgrade in the future if we
need to support new Cloudflare features. Alternatively, if we're blocked, it may require
us to fork Terrascript to introduce the required changes. This trade-off should be
considered as another data point for the priority of the larger initiative of removing
our dependencies on Terrascript of Terraform < 1.x.

It is worth mentioning that Jean-Francois Chevrette completed some initial testing that
would suggest there aren’t any immediate incompatibility issues with our known use cases
using the Cloudflare 3.x provider and Terraform 0.13.

The suggestion for now is to move forward with the **Cloudflare 3.x** provider with
Terraform 0.13 **assuming that the upgrade to Terraform 1.x is
imminent** ([SDE-1907](https://issues.redhat.com/browse/SDE-1907)). Going
directly to 3.x will avoid future technical debt of upgrading from 2.x -> 3.x. Both
versions lack community support with our current configurations, so both options are
equivalent from that perspective.

### qontract-reconcile code changes

The terraform-resources integration is responsible for provisioning AWS infrastructure
today. For Cloudflare, there are two high-level options for which integration the
Cloudflare support will be added to:

1. Create a new `terraform-cloudflare-resources` integration that will only handle the
   provisioning of Cloudflare resources. This means that terraform-resources would
   implicitly be limited to AWS resources.
2. A wrapper that abstracts the handling of >1 Client class and roughly maintains a
   subset of the TerrascriptClient API that we have today. A draft showing what that
   might look
   like [can be seen here](https://github.com/app-sre/qontract-reconcile/pull/2508).

The option to have a **separate `terraform-cloudflare-resources` integration** is the
option being proposed in this design. The pros and cons for this option are presented
below.

**Pros**

* Limits the need to modify the existing behavior of the `terraform-resources`
  integration
* Limits blast radius of failures, particularly in early development (we can disable
  either the AWS or Cloudflare integration without blocking the other)
* We can still reuse code between `terraform-resources` and
  `terraform-cloudflare-resources` by moving common functions into shared modules
* It's unlikely to be a large effort to move `terraform-cloudflare-resources` into
  `terraform-resources` in the future if we desire to do so. The upgrade to Terraform
  1.x should also provide ample refactoring opportunities.

**Cons**

* There is some minor overhead associated with adding new integrations. It doesn't seem
  that this is a major concern given there are separate terraform integrations for AWS
  resources, users, transit gateways, and DNS. In general, there is a pattern of adding
  new integrations for new use cases which is clear from the 100+ integrations that
  exist today.

For either option above, there will be a separate `TerrascriptCloudflareClient`. An
early
draft [PR for this client can be seen here](https://github.com/app-sre/qontract-reconcile/pull/2525)
. This will serve a similar purpose to the TerrascriptClient that provisions AWS
resources (which will be renamed `TerrascriptAWSClient`). There are some perceived
issues with the current TerrascriptClient as it has grown over time. The client is not
easy to test and extending it continues to make the issue worse. As such, there is an
emphasis being placed on the following goals for the new client:

1. As close to full test coverage as is possible
2. Encapsulating as much state as possible (think more use of leading underscore to
   indicate internal implementation)
3. Inject dependencies wherever possible to make testing simpler
4. Consider having a separate class per resource that is used in place of the
   `populate_tf_resource_*` method pattern used in the `Terrascript[Aws]Client`. There
   can be quite a bit of logic in these methods, so separating them and making them
   individually testable is ideal.

### qontract-schemas changes

#### Cloudflare Accounts

There is currently an `/aws/account-1.yml` schema for AWS accounts. A new
`/cloudflare/account-1.yml` schema will need to be created to support Cloudflare
accounts. The schema will be defined closer to when we begin implementing the
`TerrascriptCloudflareClient` code.
Cloudflare Resources
The Goals section of this document outlines the Cloudflare resources that will need to
be supported in our schemas. As the implementation progresses, it can be decided which
of those resources are exposed directly versus which will be implicitly created.

#### Cloudflare Resources

The Goals section of this document outlines the Cloudflare resources that will need to
be supported in our schemas. As the implementation progresses, it can be decided which
of those resources are exposed directly versus which will be implicitly created.

### Edge certificate support

Edge certificates are used to terminate TLS connections on Cloudflare servers. This edge
certificate is what is presented to the user. As per InfoSec mandates, we can currently
use either Digicert or Let's Encrypt certificates.

Using a Digicert certificate would require a manual process that starts with opening a
SNOW ticket, a certificate must be provisioned by another team, and then uploaded to
Vault for consumption by an integration. This is not ideal because it requires a manual
step and provides human access to the private key.

Cloudflare supports Advanced Certificate Manager (ACM) as an alternative that can
automatically provision Let's Encrypt certificates. This removes a manual step while
also avoiding the need for a human to generate the private key. Cloudflare having access
to the private key is no less secure because even if we generate the certificate, they'd
still need the private key that we generated to decrypt the traffic.

Utilizing the Cloudflare ACM service was the option that was chosen.

#### Certificate Domain Control Validation (DCV)

One extra bit of complexity that wasn't initially anticipated is that the DNS records
that need to be created for DCV will change each time that a certificate needs to be
renewed. Cloudflare provides the name and value of the TXT records that must be created,
but the `terraform-cloudflare-resources` integration doesn't have a good way to directly
create these DNS records. Extending the integration to support DNS record creation seems
like it would add unnecessary complexity.

The solution to overcome this will be to write the DCV values as Terraform outputs and
ultimately into Vault. These values could then be consumed by the appropriate DNS
integrations to manage the record. For now, this would only be `terraform-aws-route53`
because DCV validation records are handled automatically when a Cloudflare zone is
configured in `Full`
mode ([docs](https://developers.cloudflare.com/ssl/edge-certificates/changing-dcv-method/methods/txt/#zone-setups))
.

For example, the output would be:

```json
{
  "_acme-challenge.somedomain.local": "<dns-record-value>",
  "_acme-challenge.subdomain.somedomain.local": "<dns-record-value>"
}
```

The schema of `/dependencies/dns-zone-1.yml` could then be extended to accept values
from Vault by allowing the definition of `_records_from_vault` instead of the normal
`records` field.

```yaml
records:
  - name: _acme-challenge.test-from-vault
    type: TXT
    _records_from_vault:
      - path: some/vault/path
        field: validation_records
        key: _acme-challenge.test-from-vault.dev-data.domain.local
```

The intent is that this would only be used sparingly for dynamic values, particularly
related to DCV. This would be documented as such.

Putting this all together, the workflow would roughly look like:

1. User defines the certificate to be
   created ([docs](https://gitlab.cee.redhat.com/service/app-interface#manage-cloudflare-zone-via-app-interface-openshiftnamespace-1yml-using-terraform))
2. User determines the Vault path that the outputs with the DCV records will be stored
   in (`integrations-output/<integration_name>/<cluster>/<namespace>/<resource>`). This
   will be documented.
3. User creates the entry in their `/dependencies/dns-zone-1.yml` file corresponding to
   the DCV domain and provides the required `_records_from_vault` data

The other alternative that was considered was to use
the [mr](https://github.com/app-sre/qontract-reconcile/tree/master/reconcile/utils/mr)
package within qontract-reconcile to automatically create merge requests when a DCV
value has changed. The primary disadvantage is that this is adding a new responsibility
to the `terraform-cloudflare-resources` integration without any real benefit. It's
already a standard practice to have Terraform outputs that are used to pass values to
other resources that need them.

Overall, this is currently perceived to be a pattern that will have limited use, and
will be documented such that it should only be used for DCV. The primary benefit is that
we will no longer need to manually update DCV DNS entries every 60 days. The cost of
changing the approach in the future would be limited as long as this is only used for
DCV records.

#### Open questions

1. Do we support both `records` and `_records_from_vault` for the same DNS record?
    * Leaning towards this not being required because the use case here is primarily Let's Encrypt DCV entries which are very specific `_acme-challenge` and are unlikely to have static values

## Alternatives considered

### Upgrade to Terraform >= 1.0

Upgrading Terraform would mean that our usage of the Cloudflare 3.x provider is
community supported. The issue is
that [Terrascript does not explicitly support Terraform >= 1.0](https://pypi.org/project/terrascript/)
. Even if we wish to accept the risk of running in an unsupported configuration, we’d
also need to add the capability to upgrade Terraform on a per-account basis. Overall,
this work is outside of the scope of adding Cloudflare support.

### Upgrade to Terraform >= 1.0 and introduce Terraform CDK

The Terraform CDK and Terraform >= 1.0 is a supported configuration. The issues with
this approach are:

1.

The [Terraform CDK is still not a stable API](https://www.terraform.io/cdktf#project-maturity)
, so there is an expectation of breaking changes that will introduce more work for
upgrades

2. The Terraform CDK is a new technology that we need to adopt and figure out how to
   adapt to our use cases. This will increase the scope of the project and as a result
   reduce the likelihood of delivering Cloudflare support in 2-3 months.

## Milestones

1. Provision Cloudflare zones
2. Provision all other Cloudflare resources except Cloudflare Workers
3. Provision Cloudflare Workers including deployment of code changes

## Risks/Concerns

### qontract-reconcile support

The following risks/concerns are related specifically to the implementation in
app-interface:

1. Cloudflare Workers doesn’t appear to be a standard infrastructure component because
   it
   also [requires managing code](https://developers.cloudflare.com/workers/get-started/guide/)
   . This will make this aspect a bit more like a deployment mechanism in some ways than
   strictly infrastructure.
    1. Quay’s code for this component currently exists in
       the [this repo](https://github.com/quay/quay-cloudflare-cdn-worker)

### Operational

The following risks/concerns are being tracked towards the path to making this solution
production-ready.

1. How will we get metrics from Cloudflare for alerting? Is there a preferred exporter?
2. What is the SLA for a response from Cloudflare support?
