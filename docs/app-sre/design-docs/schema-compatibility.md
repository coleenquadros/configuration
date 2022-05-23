# Design doc: Schema Compatibility

## Author/date

Maor Friedman / 2022-05-17

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-5561

## Problem Statement

Some tenants use data from app-interface for their own automations. This may include developer oriented tools or ProdSec generated metadata.

App-interface in the scope of this document is only the commercial app-interface instance. namely, https://app-interface.devshift.net.

Introducing breaking changes to the app-interface schema may break the tenants' automations, and this is something we prefer to avoid.

## Goals

1. Avoid introducing changes that break tenants' automations.

1. Define SLAs required from teams to follow up on schema changes. Our schema changes should be backwards compatible in a way that allows for long notification periods.

## Non-objectives

* Avoid introducing schema breaking changes. These will happen from time to time, and the intention is to enable collaboration with the tenants.

## Proposal

To avoid breaking tenants' automations that rely on app-interface, we need to make app-interface aware of the queries tenants are using in their automations. Differently worded, tenants should be able to declare queries they are using and request to be notified for breaking changes.

For that purpose, we will introduce a new schema, `query-validation-1`, which will include the common fields, such as `name` and `description`. In addition, it will include a `queries` field.

This field will be a list of references (paths) to resources (files under the `resources/` directory) which are a file containing a graphql query. Some examples can be found under `resources/queries`. This list will be the queries used in the tenants' automations, and that we need to avoid from breaking. This means that we only need to notify tenants for breaking changes that affect their queries.

In addition to the schema, we will create an integration (`query-validator`). This integration acts on `query-validation-1` files. The integration will be pretty straight forward: For each entry in the `queries` list, execute the query. If it fails - fail the integration.

This integration will only run within app-interface pr-check to gate merges of schema promotions that break the tenants' queries. In case this integration fails, we will contact the responsible team to make adjustments to their source code and to the queries in app-interface.

Once the tenants' source code was changed, together with the query files in app-interface (referenced from a `query-validation-1` file), AppSRE is clear to merge the (no-longer) breaking schema changes.

We should generally avoid breaking schema changes. At the minimum, changes should be backwards compatible to allow some time before introducing the breaking change. With that said, this design document comes as a result of a tenant request. The tenant requested 1-2 working days, so we will use that as the SLA for tenants at first.

## Alternatives considered

- "hacking" this proposal by using a ConfigMap. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/39145. This example does prove the feasibility of the proposal described in this design document.

## Milestones

1. Implement
2. Document
3. Leverage
