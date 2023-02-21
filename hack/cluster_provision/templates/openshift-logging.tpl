---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: openshift-logging
description: {cluster} openshift-logging namespace

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/app-sre/app.yml

environment:
  $ref: /products/app-sre/environments/{environment}.yml

managedExternalResources: true

externalResources:
- provider: aws
  provisioner:
    $ref: /aws/app-sre-logs/account.yml
  resources:
  - provider: aws-iam-service-account
    identifier: log-forwarder-{cluster}
    output_resource_name: app-sre-logs-cloudwatch-access
    user_policy:
      {{
        "Version": "2012-10-17",
        "Statement": [
          {{
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:DescribeLogGroups",
              "logs:DescribeLogStreams",
              "logs:PutLogEvents",
              "logs:GetLogEvents",
              "logs:PutRetentionPolicy",
              "logs:GetLogRecord",
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
          }}
        ]
      }}

managedResourceTypes:
- Subscription.operators.coreos.com
- OperatorGroup.operators.coreos.com
- ClusterLogging.logging.openshift.io
- ClusterLogForwarder.logging.openshift.io

sharedResources:
- $ref: /services/app-sre/shared-resources/cluster-logging-operator.yaml
- $ref: /services/app-sre/shared-resources/cluster-logging-config.yaml
