# Design doc: Support for additional provisioning providers

## Author/date

Maor Friedman / 2022-02-08

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4611

## Problem Statement

By using `terraformResources` we are only able to provision resources in AWS. We need to be able to support provisioning resources in additional providers, such as GCP projects, and in the future - CNA.

## Goals

Enable a way to support additional terraform provisioners. A use case to focus on can be a managed DNS zone via GCP.

## Non-objectives

## Proposal

Introduce a new section in a namespace file which will support additional providers, in addition to AWS:
```yaml
externalResources:
- provider: aws
  provisioner:
    $ref: /aws/example/account.yml
  resources:
  - provider: route53-zone
    identifier: zone1-example-com
    name: zone1.example.com
    output_resource_name: aws-dns-creds
```

Each entry holds a `provider` field, which will indicate the type of the "provisioner" to use (AWS account, GCP project, the CNA service, etc). The `provisioner` field will reference an object that implements an ability to provision resources using terraform. The `resources` section will include all resources to be provisioned in this provisioner.

Such an approach is future compatible with adding new providers. For example, GCP project:
```yaml
externalResources:
- provider: gcp-project
  provisioner:
    $ref: /gcp/example/project.yml
  resources:
  - provider: managed-zone
    identifier: zone2-example-com
    name: zone2.example.com
    output_resource_name: google-dns-creds
```

This approach is backwards compatible, as it will not change the way we handle (AWS) resources managed in `terraformResources` sections.

It also follows the Provider Pattern: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-interface/qontract-reconcile-patterns.md#the-provider-pattern

Side note: This proposal is also adding "grouping" of resources of the same provider. This is instead of having each item define the same section. Most namespaces have multiple resources of the same provider (in our case, same AWS account), and this will reduce a lot of duplication and will add consistency with other areas, such as `quayRepos`.

## Alternatives considered

Keep using the `terraformResources` section. This will require a thorough change to qontract-reconcile, as we currently hard code the `account` in each entry.

## Milestones

- Perform any required refactors to simplify and prepare for additional providers.
- Create follow up tickets to migrate resources from `terraformResourcse` to `externalResources`.
- Bonus points: Implement managed zone via GCP.
