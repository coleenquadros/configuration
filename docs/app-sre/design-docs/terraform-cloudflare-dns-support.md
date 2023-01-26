# Design doc: Support DNS zones using Cloudflare

## Author/date
`jfchevrette` / `Nov 14, 2022` 

## Tracking JIRA
https://issues.redhat.com/browse/APPSRE-6540

https://docs.google.com/document/d/1RdbUbD4AZOqJvd5MDJeYnTTmhgbNTIIJbwnz1hVAfuI/edit

## Problem Statement
Oracle Dyn Managed DNS will be retired in May 2023 and SREP has multiple DNS zones that need to be migrated elsewhere

Cloudflare has been chosen as a DNS provider and it has been decided that DNS zone & record management will be done via app-interface

TL;DR:
* SREP is using Dyn DNS for various DNS zone needs
* Dyn's managed DNS offering is going to be retired in 2023
* Decision has been made to move to Cloudflare
* App-Interface will be the IaC solution for SREP and other teams to manage DNS records in Cloudflare

## Goals
* Ability to create and manage Cloudflare resources
  * [cloudflare_zone](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone)
  * [cloudflare_record](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record)
    * Support for: A, CNAME, TXT, DNSSEC
    * Must be able to set up CNAME at apex (usually not allowed in DNS, but Cloudflare supports it)
* Ability for SREP or other teams to self-service DNS records (SREP to approve)

## Non-goals

* Support for any Cloudflare services. The scope here is purely DNS zone management, no Cloudflare cache, no Cloudflare proxy)
* Multiple DNS accounts (to have DNS redundancy across multiple providers)
* [External DNS zone support](https://gitlab.cee.redhat.com/service/app-interface#manage-external-dns-zones-via-app-interface-openshiftnamespace-1yml): this pattern was discussed and is not something SREP needs. All zones and records will be managed in app-interface and through the existing MR process

## Proposal

### Cloudflare DNS terraform provider

A new terraform integration will be created to handle DNS zones, similarly to `terraform-aws-route53`. No name has been decided at this stage but something like `terraform-cloudflare-dns` might do.

#### DNS record support & DNSSEC

The following record types need to be supported
* A
* NS
* CNAME
* DS
* DNSKEY
* MX (notably has more than a value field so schema may need to be tweaked a bit)

Additionally, the integration and schema need to support enabling DNSSEC on a zone using the `cloudflare_zone_dnssec` resource type: https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_dnssec

The integation will output the DS attribute which is exported by the `cloudflare_zone_dnssec` to vault under `app-sre/integrations-output/terraform-cloudflare-dsn/ZONENAME/` so that the information can be retrieved and given to SREP to update the DS record at the domain registry

#### Schema

This integration will define a new schemas such as `/cloudflare/dns-zone-1.yml` and `/cloudflare/dns-record-1-yml`. The existing schema `/cloudflare/terraform-resource-1.yml` will be adjusted to re-use the new `/cloudflare/dns-zone-1.yml` schema. The intent is to make the new schemas re-usable between both integrations (through `/cloudflare/terraform-resource-1.yml` in the case of `terraform-cloudflare-resources`). It can however have fields that are processed differently by either integration or simply ignored by one or the other.

For `terraform-cloudflare-dns`, it might be needed to add a few parameters:
* `partial` to support [Cloudflare partial zone](https://developers.cloudflare.com/dns/zone-setups/partial-setup/setup/) creation
  * Cloudflare by default only support full zones, where a zone can only be the APEX of a domain (ex: foo.com)
  * Partial support is akin to DNS delegation in other DNS systems where it becomes possible to create a subdomains as a zone (ex: bar.foo.com) and delegate from the APEX zone

#### State

Terraform state will be stored in AWS S3, as this is where we store state for all terraform based integrations

#### Sharding

In order to improve performance and reduce impact of a large DNS zone over the others, integration sharding will be implemented right from the get go, similarly to other integrations which support sharding. Sharding should be implemented per zone for performance reasons (SREP's account will have many zones and a large # of records total). As such we will have to change the terraform state to store state per zone instead of per record. We must take care of ensuring no duplicate zone is able to be created in two different states (check all accounts are unique, check all zones are unique - for instance two differently named data files could contain the same account name or the same zone name)

#### Performance

In testing, it was shown that terraform could take as much as 30 minutes to analyze and reconcile 30,000 records during which CPU was saturated and memory raised up to 3 GB (tests done on a Macbook Pro with aarch64 CPU)

In another test with 1000 records, the results were much more reasonable.

| Records | tf plan | td apply           | tf plan (after apply) | tf plan_delete | tf apply delete |
|---------|---------|--------------------|---------|----------------|-----------------|
| 1000    | 10s     | 520s               | 260s    | 250s           | 500s            |
| 30,000  | 500s    | 1h + timeout (TBD) | TBD     | TBD            | TBD             |

**Note: ** This is currently difficult to test as we do not have access to an account which has available capacity and increased zone record limits to test with. This will be discussed with our Cloudflare reps and this document will be updated when further testing is conducted

To keep the performance characteristics of the itnegration under control, AppSRE will only support up to 1000 records per zone to begin with. The integration will have a default `max_records` which will return an error if reconciling a zone with total record count over that amount

### Import records from Dyn to Cloudflare

A rudimentary tool called [dyn-migrate](https://gitlab.cee.redhat.com/jchevret/dyn-migrate) has been created to get information about zones and records from Dyn. The tool also has the ability to dump a yaml representation of the zone and records whcih is compatible with the dns-zone-1 schema we have in app-interface

The migration will consist of exporting the DNS information from Dyn into one yaml file per zone matching the `/dependency/dns-zone-1.yml` schema. Upon merging those files, the DNS entries will be created in the Cloudflare account. The same process will be used to sync any changes prior to the migration.

**This task will be executed by SREP. SREP will also need to coordinate the update of the nameservers for each domain**

### Special import of rhcloud.com

The rhcloud.com zone is split out into 11 sub-zones (dev.rhcloud.com, int.rhcloud.com, qe.rhcloud.com) which amount to over 30,000 DNS records. Such a large number of zones is not easy to support as terraform has performance issues when a very large number of resources (records) are direct dependents of another resource (zone)

In order to keep the integration run time and resource utilization within good range, two options were proposed:
* Do a massive cleanup the *.rhcloud.com DNS zones
* Initially import all DNS zone records in Cloudflare, but unmanaged by app-interface
  * Records added to the zone outside of app-interface/terraform will not be deleted by terraform (to be validted)
  * New records will be added via app-interface as normal
  * Any need to update or delete an existing record will have to be a ticket to AppSRE
    * ... or possibly to a group within SREP who has access to the Cloudflare UI (TBD, out of scope of the initial proposal)

### FedRAMP

Some zones use DNSSEC which is mandated for FedRAMP environments. After discussion with SREP it was concluded that these zones can exist in the commercial app-interface and still be compliant with FedRAMP

## Alternatives considered

### Re-use / extend the terraform-cloudflare-resources integration

AppSRE has implemented similar functionnality as part of [SDE-1958](https://issues.redhat.com/browse/SDE-1958) for the specific goal of supported Cloudflare workers for Quay.io. As such this functionality has been implemented as an external resource, within namespaces resources. This does not fit the requirement well here as the DNS zones are not tied to a service nor to a namespace. Furthermore, the proposal makes more sense in that it let each DNS zone be its own file, compared to the external resource pattern where zones are nested under a namespace (we could have 1 namespace per zone but this is more cumbersome than beneficial)

## Milestones
* M1: Create and manage Cloudflare DNS zones and records
* M2: Document & test importing a large zone from Dyn to validate the integration
* M3: Enable SREP to self-serve DNS changes

## Pending questions/concerns/unknowns
* Performance with many records (>1000)
  * Although we've done some testing above, we could not conduct extensive testing as we did not have an account with adequate quota at the time of writing this design doc
  * During the implementation phase we should have access to the new Cloudflare account which we will use to further experiment with many records 
  * Link to thread: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/51692#note_5583251
* Sharding
  * At the time of writing this doc, there are ongoing discussions on sharding method and new sharding techniques (ex: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/55171)
  * Sharding par account is the more common case at the moment
  * We believe sharding per zone will be preferable for performance reasons
  * Sharding per zone may increase resource requirements considerably. At the moment this will mean we would run 36 shards which is much more than we've ever run for an integration
  * Link to thread: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/51692#note_5583354
