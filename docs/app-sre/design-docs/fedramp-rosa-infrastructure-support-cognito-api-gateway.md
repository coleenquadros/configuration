# ROSA Infrastructure Support Proposal for App Interface in FedRAMP

[toc]

## Author/date

Tyler Pate / 2022-05-09

## Tracking JIRA

https://issues.redhat.com/projects/APPSRE/issues/APPSRE-5480

## Problem Statement

A recent strategy shift in the buildout of the FedRAMP / GovCloud Red Hat product offering has led to a new requirement to provide ROSA clusters to GovCloud customers, in lieu of an OSD based approach. This shift has necessitated a full strategy and engineering review of the future product to ensure the combined teams can meet technical and compliance requirements.

There are a multitude of differences between the commercial and FedRAMP environments - too many to include a full list here. However, for the purposes of this proposal, the important differences are as follows:

- RH SSO / Keycloak is administered by a third party contractor, StackArmor. Both the active directory and the instance of keycloak are completely disconnected from commercial solutions.
- Usage of an out-of-boundary authentication or authorization method is not approved in FedRAMP controls.

A solution is required that will allow the ROSA engineering team to manage an OIDC authorization provider, as well as a method to expose the authorization provider to the public internet (to allow usage of ROSA-cli).

## Supplemental Design Documentation

- [Self-servicve ROSA on GovCloud](https://docs.google.com/document/d/1YPa9S517RFDPYKnilX14G5MMN0ovGvFSG45cU3SCCk8/edit)
- [Self-service ROSA for FedRAMP (first draft of the document above)](https://docs.google.com/document/d/1JHYFFDqls_ZfjoHmVhG_Xug725NvFwmanCQLB_PE_7k/edit)

## Goals

- Add support in qontract-reconcile for managing AWS Cognito resource types
- Add support in qontract-reconcile for managing AWS API Gateway resource types

## Non-objectives

- User management in app-interface for Cognito users (these users are customers, not Red Hat employees)
- Advanced or extended usage of Cognito outside of the narrow definition in this proposal
- Advanced or extended usage of API Gateway outside of the narrow definition in this proposal

## Proposal

I reviewed the capacities of the AWS Terraform provider version 3.60.0, as supported by Terrascript in our usage in qontract-reconcile. Based on this investigation, the management of Cognito and API Gateway resources are both possible with this version combination.

- [Cognito Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/cognito_identity_provider)
- [API Gateway Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/3.60.0/docs/resources/api_gateway_resource)

### Cognito

We will update terraform-resources integration to support the configuration of AWS Cognito, strictly limited to the configuration of said resource, and will not include support for managing specific users in a user pool.

The management of user lists for Cognito is specifically out of scope for this effort - the potential issues around reconciliation of a user list is just the start of the problems, let alone mixing Red Hat employee internal management with customer management.

As it maps to specific Cognito resources, I feel the following can easily be classified as “configuration” and as such would work well with the reconciliation model. Note, “user_pool” in cognito just provides a container for users, but does not populate a user list. Some work will need to be done to validate that reconciliation differences do not appear in user pool resources if user lists change.

The following terraform resources are used in the demo implementation from SREP:

- aws_cognito_user_pool
- aws_cognito_user_pool_client
- aws_cognito_user_pool_domain
- aws_iam_role
- aws_iam_role_policy

### API Gateway

In addition to the proposed changes to terraform-resource which support Cognito, we will also need to add support for API Gateway. I feel the overall risk for inclusion of the API gateway is lower than Cognito, as there are less constantly changing parts (i.e. user lists).

Importantly, there is a single shared variable from the Cognito definition that will be referenced in API Gateway resources.

The following terraform resources are used in the demo implementation from SREP:

- aws_api_gateway_rest_api
- aws_api_gateway_resource
- aws_api_gateway_method
- aws_api_gateway_authorizer
- aws_api_gateway_deployment
- aws_api_gateway_stage
- aws_api_gateway_integration

## Details

### Cognito Terraform Definition

```
resource "aws_iam_role" "sms_role" {
  name        = "${var.organization_name}-SMS"
  description = "role for applicant cognito, send sms"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Condition = {
            StringEquals = {
              "sts:ExternalId" = "${var.aws.sms_role_ext_id}"
            }
          }
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "cognito-idp.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/service-role/"
}

resource "aws_iam_role_policy" "inline_policy" {
  name = "cognito_sms"
  role = aws_iam_role.sms_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "sns:publish"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_cognito_user_pool" "pool" {
  name                       = "${var.organization_name} pool"
  mfa_configuration          = "OPTIONAL"
  email_verification_message = "Your verification code is {####}. "
  email_verification_subject = "Your verification code"
  sms_verification_message   = "Your verification code is {####}. "
  sms_authentication_message = "example-1234{####}"
  sms_configuration {
    external_id    = var.aws.sms_role_ext_id
    sns_caller_arn = aws_iam_role.sms_role.arn
  }
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  auto_verified_attributes = ["email"]
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
  schema {
    name                     = "preferred_username"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
}

resource "aws_cognito_user_pool_domain" "userpool_domain" {
  domain       = var.aws_cognito_user_pool_domain
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name            = "${var.organization_name}-pool-client"
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = true
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
  ]
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile"
  ]
  allowed_oauth_flows_user_pool_client = true
  callback_urls                        = var.callback_urls
  supported_identity_providers         = ["COGNITO"]
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo"
  ]
}
```

### Cognito App-Interface Representation Proposal

```
terraformResources:
- provider: cognito
  # maps to the following resources:
  # - aws_iam_role
  # - aws_iam_role_policy
  # - aws_cognito_user_pool
  # - aws_cognito_user_pool_domain
  # - aws_cognito_user_pool_client
  # - aws_cognito_user_pool_client
  account: appsrefrp01ugw1
  identifier: rosa-cognito
```

### Cognito Defaults File

```
  user_pool_properties:
    mfa_required: false
    admin_create_user_restriction: true
    auto_verified_attributes:
    - email
    notifications:
    - email:
        verification_message: "Your verification code is {####}"
        verification_subject: "Your verification code"
    - sms:
        verification_message: "Your verification code is {####}"
        authentication_message: "example-1234{####}"
    domain: redhat-fedramp-govcloud
    schemas:
    - name: email
      data_type: String
      string_constraints:
      - min_length: 0
      - max_length: 2048
      developer_only: false
      mutable: true
      required: true
    - name: name
      data_type: String
      string_constraints:
      - min_length: 0
      - max_length: 2048
      developer_only: false
      mutable: true
      required: true
    - name: preferred_username
      data_type: String
      string_constraints:
      - min_length: 0
      - max_length: 2048
      developer_only: false
      mutable: true
      required: true
  user_pool_client_properties:
    generate_secret: true
    auth_flows:
    - ALLOW_REFRESH_TOKEN_AUTH
    - ALLOW_USER_PASSWORD_AUTH
    oauth_flows:
    - implicit
    oauth_scopes:
    - email
    - openid
    - profile
    callback_urls:
    - fedramp.devshift.net/oauth
    identity_providers:
    - COGNITO
    read_attributes:
    - address
    - birthdate
    - email
    - email_verified
    - family_name
    - gender
    - given_name
    - locale
    - middle_name
    - name
    - nickname
    - phone_number
    - phone_number_verified
    - picture
    - preferred_username
    - profile
    - updated_at
    - website
    - zoneinfo
    write_attributes:
    - address
    - birthdate
    - email
    - email_verified
    - family_name
    - gender
    - given_name
    - locale
    - middle_name
    - name
    - nickname
    - phone_number
    - phone_number_verified
    - picture
    - preferred_username
    - profile
    - updated_at
    - website
    - zoneinfo
```

### API Gateway Terraform Definition

```
# API Gateway
resource "aws_api_gateway_rest_api" "gw_api" {
  name        = "${var.organization_name}-rest-api"
  description = "API to be used by cognito"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "gw_resource" {
  parent_id   = aws_api_gateway_rest_api.gw_api.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.gw_api.id
}

resource "aws_api_gateway_method" "gw_method_any" {
  rest_api_id   = aws_api_gateway_rest_api.gw_api.id
  resource_id   = aws_api_gateway_resource.gw_resource.id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.gw_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_authorizer" "gw_authorizer" {
  name            = "${var.organization_name}-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.gw_api.id
  provider_arns   = [aws_cognito_user_pool.pool.arn]
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
}

resource "aws_api_gateway_deployment" "gw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.gw_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.gw_resource.id,
      aws_api_gateway_method.gw_method_any.id,
      aws_api_gateway_integration.gw_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "gw_stage" {
  deployment_id = aws_api_gateway_deployment.gw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.gw_api.id
  stage_name    = "stage"
}

resource "aws_api_gateway_integration" "gw_integration" {
  rest_api_id = aws_api_gateway_rest_api.gw_api.id
  resource_id = aws_api_gateway_resource.gw_resource.id
  http_method = aws_api_gateway_method.gw_method_any.http_method

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  type                    = "HTTP_PROXY"
  uri                     = var.api_proxy_uri
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"

  connection_type = "INTERNET"
}
```

### API Gateway App-Interface Representation Proposal

```
terraformResources:
- provider: api-gateway
  # maps to the following resources:
  # - aws_api_gateway_rest_api
  # - aws_api_gateway_resource
  # - aws_api_gateway_method
  # - aws_api_gateway_authorizer
  # - aws_api_gateway_deployment
  # - aws_api_gateway_stage
  # - aws_api_gateway_integration
  account: appsrefrp01ugw1
  identifier: rosa-api-gateway
  api_proxy_uri: api.fedramp.devshift.net
```

### API Gateway Defaults File

```
rest_api_properties:
    description: api gatway supporting cognito
    endpoint_configuration_types:
    - REGIONAL
  gateway_resource_properties:
  - path_part: "{proxy+}"
  gateway_method_properties:
    http_method: ANY
    authorization: COGNITO_USER_POOLS
    request_parameters:
    - "method.request.path.proxy": true
  gateway_authorizer_properties:
    provider_arns:
    - aws_cognito_user_pool.pool.arn # this will be an external reference.
                                     # have to figure out the best method to connect the two resource types together.
                                     # looking for ideas.
    type: COGNITO_USER_POOLS
    identity_source: "method.request.header.Authorization"
  stage_name: stage
  integration_properties:
    request_parameters:
    - "integration.request.path.proxy": "method.request.path.proxy"
    type: HTTP_PROXY
    http_method: ANY
    passthrough_behavior: WHEN_NO_MATCH
    connection_type: INTERNET
```

## Alternatives Considered

API Exposure

- AWS API Gateway
- Boundary firewall rule + OCM API internal routing
- AWS ELB

Authentication

- Keycloak
- RH-SSO

## Milestones

- Add support for Cognito Resources in terraform-resources integration
- Add support (if required) for a new schema type which models Cognito resources.
- Add support for API Gateway in terraform-resources integration
- Reconcile yaml definitions of Cognito resources in FedRAMP environment
- Reconcile yaml definitions of API Gateway resources in FedRAMP environment
