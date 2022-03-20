# Design doc: terraform resources output secret format

## Author/date

Gerd Oberlechner / March 202

## Tracking Jira

## Problem Statement
terraform-resource outputs (credentials etc) are placed into their respective
namespaces as kubernetes `Secrets`. The contents of those secrets are defined
by the terraform output variables. At times an application/services requires
a different formatting of those secrets. An existing solution that is sometimes used
leverages `openshiftResources` consuming the terraform secret placed into vault
in a template, but this is more involved and the terraform resource and
the secret need to be added to app-interface in two consecutive MRs.

This design doc was motivated by
* Hypershift requires AWS access credentials to an S3 bucket formatted in the credentials file format
* mimicking `CloudCredentialsOperator` secrets containing the aws_xxx fields and a credentials field

## Goals
Tenants should be able to influence the format of a terraform output secret to
match the expectation of the application/services that consumes it.

## Proposal
This schema changes proposal introduces a field `output_resource_template` to
terraform resources. this field defines the `path` portion of a
`/openshift/openshift-resource-1.yml` that behaves like a resource with
`provider: resource-template` and `type: jinja2`. alternatively we could
reference an actual `/openshift/openshift-resource-1.yml`, but then
the implementing integration needs to verify `provider` and `type`.

the integration implementing this schema change will need validate that the
resulting manifest is of `kind: Secret`.

### Example
The terraform resource defines `output_resource_template` ...

```yaml
  ---
  $schema: /openshift/namespace-1.yml
  ...
  terraformResources:
  - provider: aws-iam-service-account
    account: account
    identifier: log-forwarder-xxx
    output_resource_template: /setup/clusterlogging/log-forwarder-iam.secret.yaml
    user_policy:
      {
        "Version": "2012-10-17",
        ...
      }
```

... and a resource file with this content

```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: instance
  type: Opaque
  stringData:
    aws_access_key_id: {{ aws_access_key_id }}
    aws_secret_access_key: {{ aws_secret_access_key }}
    credentials: >-
      [default]
      aws_access_key_id = {{ aws_access_key_id }}
      aws_secret_access_key = {{ aws_secret_access_key }}

```

the terraform output variables are available as jina2 template variables.

## Alternative
Since both cases motivating this change are basically the same, namely providing different formatting for AWS credentials, we could also add a `format` field to the `aws-iam-service-account` provider in the `/openshift/terraform-resource-1.yml` schema. A `format` would be a predefined `provider` specific way of formatting its secrets, e.g. `format: accesskey-secretkey | credentials-file | accesskey-secretkey-credentials-file`. This would be a more localized solution that is less flexible but also more robust and less errorprone.

### Example

The `accesskey-secretkey-credentials-file` format could be defined like the
template specified in the proposal. Using it like this, would result in the
same output secret as in the proposal.

```yaml
  ---
  $schema: /openshift/namespace-1.yml
  ...
  terraformResources:
  - provider: aws-iam-service-account
    account: account
    identifier: log-forwarder-xxx
    output_secret_name: instance
    format: accesskey-secretkey-credentials-file
    user_policy:
      {
        "Version": "2012-10-17",
        ...
      }
```
