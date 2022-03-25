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
Tenants should be able to influence the format of a terraform output secret to match the expectation of the application/services that consumes it.

## Proposal

Provide an `output_format` section to `/openshift/terraform-resource-1.yml`. This section will hold configuration data to drive the formatting process for terraform output data.

To make the process backwards compatible with the current way of exposing secrets, a provider `generic-secret` will be implemented that will take the output variables from a terraform provider as keys for the `data` section of a secret. If a `terraformResource` has no `output_format.provider` defined, `generic-secret` is assumed as default. This way, the following two terraform resources definitions are considered identical:

```yaml
  terraformResources:
  - provider: aws-iam-service-account
    ...
```

```yaml
  terraformResources:
  - provider: aws-iam-service-account
    output_format:
      provider: generic-secret
    ...
```

To address the cases motivating this this design document, a templated way to define the secret content can be declared with `output_format.data`. The terraform output variables can be used as template variables.

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

## Future enhancements

### Well known formats

Additional providers can be implemented to address common output formats, e.g. providing a credentials file for AWS access information instead of access key and secret access key individually.

e.g.

```yaml
  ---
  $schema: /openshift/namespace-1.yml
  ...
  terraformResources:
  - provider: aws-iam-service-account
    output_secret_name: instance
    output_format:
      provider: aws-credentials-file
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
    credentials: >-
      [default]
      aws_access_key_id = {{ aws_access_key_id }}
      aws_secret_access_key = {{ aws_secret_access_key }}
```

Such providers can be added as needed for well known reusable formats.

### Reusable templates

For more complex custom formats that are used repeatedly or that are too big to be declared/repeated inline, a `resource-template` provider can be implemented, that allows referencing a resource file with jinja2 contents and that leverages explicity or implicitly defined `output_format.data` as template variables.

### Configmaps

Similar to the `generic-secret` provider, also a `generic-configmap` provider could be implemented exposing terraform output as configmaps. Since configmaps can be inspected by tenants, we would need to find a way to make sure only non-sensitive data can be exposed this way.

# Milestones
Implement the `generic-secret` provider and cover the cases motivating this design doc with it. Options mentioned in the `future enhancement` sections are not subject for immediate implementation.
