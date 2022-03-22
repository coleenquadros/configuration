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
Since both cases motivating this change are basically the same, namely providing different formatting for AWS credentials, we can add a `format` field to the `aws-iam-service-account` provider in the `/openshift/terraform-resource-1.yml` schema. A `format` would be a predefined `provider` specific way of formatting its secrets, e.g.:

* `accesskey-secretkey` - list `aws_access_key_id` and `aws_secret_access_key` in the secret
* `accesskey-secretkey-credentials-file` - also list `credentials` in the secret containing a full AWS credentials file

The `format` field can be implemented individually for each terraform provider when needed.

### Example

Declaring a terraform resource like this ...

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

will result in a secret like this

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

## Alternative
Instead of a `format` field defining implicit static output, introduce a field
`output_resource_template` on terraform resources. This field defines the `path`
portion of a `/openshift/openshift-resource-1.yml` That behaves like a resource with
`provider: resource-template` and `type: jinja2`.

The integration implementing this schema change would need to validate that the
resulting manifest is of `kind: Secret`.

This alternative would be more flexible for tenants to use but would also be
more complicated and errorprone to use. The reason, this was made the alternative
and not the actual proposal, was the fact that we don't need the flexibility
right now. Also there is a way forward adding this next to `format` if required.

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

The terraform output variables are available as jina2 template variables.

# Milestones
The effort to implement this is rather small and there are only a couple of
cases that need to be migrated to this. So the proposal in this design doc
can be implemented in one go.
