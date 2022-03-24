# Design doc: terraform resources output secret format

## Author/date

Gerd Oberlechner / March 2022

## Tracking Jira
https://issues.redhat.com/browse/APPSRE-4619

## Problem Statement
`terraform-resource` outputs (credentials etc) are placed into their respective
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

Since both cases motivating this change are basically the same, namely providing different formatting for AWS credentials, we can add a `output_format` section to the `aws-iam-service-account` provider in the `/openshift/terraform-resource-1.yml` schema. `output_format` would hold
configuration data to drive the formatting process.

```yaml
  terraformResources:
  - provider: aws-iam-service-account
    output_format:
      provider: accesskey-secretkey-credentials-file
    ...
```

e.g. for `aws-iam-service-account`, the following `output_format.provider` values would solve
the issues motivated by this design doc:
* `accesskey-secretkey` - list `aws_access_key_id` and `aws_secret_access_key` in the secret
* `accesskey-secretkey-credentials-file` - also list `credentials` in the secret containing a full AWS credentials file

Additional `output_format.provider`s can be added individually for each terraform provider when needed.

### Example

Declaring a terraform resource like this ...

```yaml
  ---
  $schema: /openshift/namespace-1.yml
  ...
  terraformResources:
  - provider: aws-iam-service-account
    output_secret_name: instance
    output_format:
      provider: accesskey-secretkey-credentials-file
    ...
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

## Future enhancements

Provide generic output format providers that allow templated approaches to rendering. e.g.

```yaml
  ---
  $schema: /openshift/namespace-1.yml
  ...
  terraformResources:
  - provider: aws-iam-service-account
    output_format:
      provider: generic-secret
      data:
        aws_access_key_id: {{ aws_access_key_id }}
        aws_secret_access_key: {{ aws_secret_access_key }}
        credentials: >-
          [default]
          aws_access_key_id = {{ aws_access_key_id }}
          aws_secret_access_key = {{ aws_secret_access_key }}
    ...
```

Making `generic-secret` the default provider if none is declared and defaulting `output_format.data` to the terraform
output variables, would make all current terraformResources forward compatible, they would render the same without
any required change.

For more complex custom formats that are used repeatedly or that are too big to be declared/repeated inline,
a `resource-template` provider can be implemented, that allows referencing a resource file with jinja2 contents
and that leverages explicity or implicitly defined `output_format.data` as template variables.

# Milestones
The effort to implement this is rather small and there are only a couple of
cases that need to be migrated to this. So the proposal in this design doc
can be implemented in one go.
