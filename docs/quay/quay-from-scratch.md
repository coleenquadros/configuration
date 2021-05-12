- [Deploy Quay from scratch](#deploy-quay-from-scratch)
  - [Pre-requisites](#pre-requisites)
  - [Create TLS certs](#create-tls-certs)
  - [Create DNS Certificates](#create-dns-certificates)
  - [Prepare Quay Database](#prepare-quay-database)
    - [Create the Database](#create-the-database)
    - [Create Users](#create-users)
  - [Create IAM user for quay](#create-iam-user-for-quay)
  - [Create CloudFront](#create-cloudfront)
  - [Create CloudFront Signing Keys](#create-cloudfront-signing-keys)
    - [Attach Signing Key to CloudFront Distribution](#attach-signing-key-to-cloudfront-distribution)
  - [Create Elasticache Instance](#create-elasticache-instance)
  - [Create a configuration file](#create-a-configuration-file)
    - [Deploy the configuration file to the cluster](#deploy-the-configuration-file-to-the-cluster)
  - [Configure syslog-cloudwatch-bridge](#configure-syslog-cloudwatch-bridge)
    - [Create an IAM User](#create-an-iam-user)
  - [Add Network Policy](#add-network-policy)
  - [Create CloudWatch Log Group](#create-cloudwatch-log-group)
  - [Deploy via saasfile](#deploy-via-saasfile)
  - [Deploy Observability](#deploy-observability)
    - [Add CloudWatch Exporter](#add-cloudwatch-exporter)
    - [Add a Service Monitor](#add-a-service-monitor)
    - [Add Quay App Monitoring](#add-quay-app-monitoring)
    - [Add Quay to Monitored Namespaces](#add-quay-to-monitored-namespaces)

# Deploy Quay from scratch

## Pre-requisites

In order to create a configuration file for quay, RDS, Elasticache, ACM and CloudFront/S3 must be configured and accesible in cluster.

## Create TLS certs

The quay.io SSL certificates are used by the quay app directly which is where TLS is terminated through the Load Balancer service

The process to generate and request a TLS certificate from IT can be found [here](docs/app-sre/sop/digicert-tls-certificates.md)

Quay SSL certificates are managed in Vault with other Quay configuration & secrets. Quay SSL certs are stored in `quay-config-secret` with keys `ssl.cert` and `ssl.key`. Secret in Vault can be found [here](quayio.md#updating-secret-in-vault)

## Create DNS Certificates

Quay uses AWS ACM (Amazon Certification Manager) for certificates.  Create the certificate by adding the following to the namespace file:

```yaml
- provider: acm
  account: <aws_account>
  identifier: <unique identifier>
  domain:
    domain_name: '<domain or wildcard'
```

Once the certificate is created in AWS, proof that the domain is under the user's control is required.  This is done by AWS requesting a specific CNAME record be added to the DNS configuration for that domain.  To find the CNAME, log into the AWS console and go to the [ACM](https://console.aws.amazon.com/acm) section.  Find the `domain name` created by the acm entry above, and expand the section by clicking on the arrow to the left of the entry.  Under the `Status` section there is a `Domain` section for this DNS domain.  Expand the entry by clicking on the arrow to the left and information will be displayed about the CNAME that needs to added to the DNS records.

The CNAME that proves control over the domain can be added to app-interface.  Docs about [managing DNS zones](https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/manage-dns-zones-using-terraform) give details about how to manage DNS zones via app-interface.  Here's an [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/dns/q1w2.quay.rhcloud.com.yaml#L24).

## Prepare Quay Database

### Create the Database

### Create Users

Need to create read-write and read-only users and read-only keypair

## Create IAM user for quay

## Create CloudFront

Quay uses cloudfront to serve content from S3 when the request is from outside AWS.  Deploy a cloudfront instance by adding this to the namespace file:

```yaml
- provider: s3-cloudfront
  account: <aws_account>
  identifier: <unqiue_identier>
  storage_class: intelligent_tiering
  defaults: /terraform/resources/ocm-quay/s3-cloudfront-us-east-1.yml
  output_resource_name: <output_name>
```

The defaults should be similar to [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/quayio-production/s3-cloudfront-us-east-1.yml).

## Create CloudFront Signing Keys

The cloudwatch signing keys are needed to sign URLs. Follow the [Create a key pair for a trusted key group](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html) section to create a key pair to use with CloudFront.  In the AWS Console, go to the [CloudFront](https://console.aws.amazon.com/cloudfront) area, and under `Key Management` select `Public Keys`.  Click the `Add public key` button at the top and create a new public key to use with CloudFront.  Give it a name and in the `Key value` field paste the contents of the public key file you just created.

Store the `ID` for the public key in vault in the `quay-additional-config` secret with the key `cloudfront_key_id`.  Here is an [example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-additional-config).

Store the public_key in vault in the `quay-additional-config` secret with the key `cloudfront_public_key_pem`.

Store the private key in vault in the `quay-config-secret` secret with the key `cloudfront-signing-key.pem1.  Here is an [example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-config-secret).

### Attach Signing Key to CloudFront Distribution

In order for cloudfront to use the public key created above we need to associate the key with the cloudfront distribution.  This currently must be done in the AWS console until terraform supports it.  See: https://github.com/hashicorp/terraform-provider-aws/pull/18644

In the AWS console go to the [CloudFront](https://console.aws.amazon.com/cloudfront) area and click on the `Distributions` section on the left.  Choose the CloudFront Distribution to be modified by clicking on the `ID` field.  Go to the `Behaviors` tab and select the listed behavior and `Edit` it.  Look for the `Restrict Viewer Access (Use Signed URLs or Signed Cookies)` section and select `Yes`.  This will create a new section called `Trusted Key Groups or Trusted Signer`.  Select `Trusted Key Groups` and choose the created key group from above in the drop down list then press `Add` next to the field.  The key group should then appear just below in the `Trusted Key Group Name` area.  When done, press the `Yes, Edit` button at the bottom of the screen.

## Create Elasticache Instance

Quay uses redis for some locking and for build queue management.  Create an elasticache instance by adding the following to the namespace file:

```yaml
- provider: elasticache
  account: <aws_account>
  identifier: <unique_identifier>
  defaults: /terraform/resources/ocm-quay/elasticache-1.yml
  parameter_group: /terraform/resources/ocm-quay/elasticache-parameter-group-1.yml
  output_resource_name: <ouput_name>
```

The [defaults](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/quayio-production/elasticache-1.yml) and [parameter_group](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/quayio-production/elasticache-parameter-group-1.yml) should be like the linked examples.

## Create a configuration file

### Deploy the configuration file to the cluster

## Configure syslog-cloudwatch-bridge

The `syslog-cloudwatch-bridge` is used to push logs from the quay pods into cloudwatch.

### Create an IAM User

A new IAM user with a correct IAM policy is needed in order to access and write to CloudWatch.  Create an IAM user with this policy by editing the namespace file and adding the following:

```yaml
- provider: aws-iam-service-account
  account: ocm-quay
  identifier: syslog-cloudwatch-bridge
  variables:
    aws_region: us-east-1
  user_policy:
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "arn:aws:logs:*:*:*"
                ]
            }
        ]
    }
```

Once the IAM user it created, apply a secret on the cluster for the syslog-cloudwatch-bridge to use with the information from the IAM user creation:

```yaml
- provider: resource-template
  type: extracurlyjinja2
  path: /ocm-quay/ocm-quay-syslog-cloudwatch-bridge-secret.yaml
```

This will convert the output from the app-interface integrations into a format that the syslog-cloudwatch-bridge can use, like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/ocm-quay/ocm-quay-syslog-cloudwatch-bridge-secret.yaml).

## Add Network Policy

Quay needs a network policy to allow external access.  Add the following to the namespace file:

```yaml
- provider: resource
  path: /quay-p/quay/quay.web-allow-external.networkpolicy.yaml
```

The network policy should look like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/quay-p/quay/quay.web-allow-external.networkpolicy.yaml).

## Create CloudWatch Log Group

CloudWatch log groups need to be created before they can be used.  The log group that will be used by quay will need to be created in CloudWatch before deploying the pods.  This must be done in the AWS console.  Log into the AWS console and go to the [CloudWatch](https://console.aws.amazon.com/cloudwatch) section.  Press the `Create log group` button in the upper right hand corner and create the log group that is configured for use with quay.  For exmaple, if the configured log group is `cluster/quay/app` then create a log group with that exact name, ie `cluster/quay/app`.

## Deploy via saasfile

Once all of the above is in place, quay can be deployed via a [saasfile](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/quayio/saas/quayio.yaml).

## Deploy Observability

Quay's monitoring architecture is documented [here](./monitoring.md).

### Add CloudWatch Exporter

Add the AWS IAM account for the cloud watch exporter by editing the [namespace](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/app-sre-observability-production.yml) file for production/stage and add a new section like:

```yaml
- provider: aws-iam-service-account
  account: <aws account>
  identifier: aws-cloudwatch-exporter-<cluster_name>
  policies:
  - CloudWatchReadOnlyAccess
  output_resource_name: aws-cloudwatch-exporter-<service_name>
```

A cloud watch exporter will need to be created in the cluster AppSRE uses for aggregating data.  Edit the [saasifile](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-cloudwatch-exporter.yaml) and add a section for the cluster with unique names:

```yaml
- name: cloudwatch-exporter-<service_name>
  path: /openshift/cloudwatch-exporter.template.yaml
  url: https://gitlab.cee.redhat.com/service/app-sre-observability
  parameters:
    CLOUDWATCH_EXPORTER: cloudwatch-exporter-<service_name>
    AWS_SECRET_NAME: <output_resource_name added above>
    CLOUDWATCH_EXPORTER_CONFIGMAP: cloudwatch-exporter-config-<service_name>
  targets:
  - namespace:
      $ref: /services/observability/namespaces/app-sre-observability-stage.yml
    ref: master
    parameters:
      REPLICAS: 1
  - namespace:
      $ref: /services/observability/namespaces/app-sre-observability-production.yml
    ref: <sha used by other production configurations>
    parameters:
      REPLICAS: 1
```

### Add a Service Monitor

Add a service monitor for the cloudwatch exporter by editing the AppSRE observability [namespace](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml) for production/stage and add a section for quay like:

```yaml
- provider: resource-template
  type: jinja2
  path: /observability/servicemonitors/cloudwatch-exporter.servicemonitor.yaml
  variables:
    namespace: app-sre-observability-<production|stage>
    name: cloudwatch-exporter-<service_name>
```

### Add Quay App Monitoring

Update the openshift-customer-monitoring file for the cluster ([ex](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.quayp05ue1.yml)) and add the following quay application monitoring entries:

```yaml
# ServiceMonitor
## Quay
- provider: resource
  path: /quay-p/quay/quay.app-sre.servicemonitor.yaml
- provider: resource
  path: /quay-p/quay/quay.aggregation.servicemonitor.yaml
- provider: resource
  path: /quay-p/quay/quay.aggregation.federation.servicemonitor.yaml


# PrometheusRule
## Quayio
- provider: resource
  path: /quay-p/quay/quay.alerts.prometheusrules.yaml
- provider: resource
  path: /quay-p/quay/quay.aggregation.prometheusrules.yaml
- provider: resource
  path: /observability/prometheusrules/kube-cronjob.prometheusrules.yaml

# Prometheus
## Quay Aggregation Prometheus
- provider: resource-template
  type: jinja2
  path: /quay-p/quay/quay.aggregation.prometheus.yaml
  variables:
    version: v2.15.2
    retention: 1h
    tempfsSize: 10Gi
    walCompression: true

# Service
## Quay Aggregation Prometheus
- provider: resource
  path: /quay-p/quay/quay.aggregation.service.yaml
```

### Add Quay to Monitored Namespaces

Finally, add the namespace where the quay application will be deployed to the list of [monitored namespace](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml#L68).
