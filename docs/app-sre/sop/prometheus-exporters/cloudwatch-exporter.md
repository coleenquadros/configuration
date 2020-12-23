# CloudWatch Exporter

## Use case

App-SRE currently uses the cloudwatch exporter to monitor and alert on our AWS resources. (S3, RDS, SQS etc.)

We use the official [Cloudwatch exporter](https://github.com/prometheus/cloudwatch_exporter) image.

## Deployment

The cloudwatch exporter is deployed under the app-sre-observability suite of services. We create a new exporter deployment for each AWS account we monitor, and deploy all the exporters centrally in the [app-sre-observability-production namespace](https://visual-app-interface.devshift.net/namespaces#/services/observability/namespaces/app-sre-observability-production.yml)

The cloudwatch exporter require an IAM user with at least a `CloudWatchReadOnlyAccess` added to it. For more details, please see the [official docs](https://github.com/prometheus/cloudwatch_exporter#credentials-and-permissions)

The cloudwatch exporter is complemented by our own [aws-resource-exporter](https://github.com/app-sre/aws-resource-exporter) project and we should make sure we deploy both together.

## Alerts

We have a [set of standard alerts](https://gitlab.cee.redhat.com/service/app-interface/blob/81116a131e0587898c56126c75f9db7981adc73d/resources%2Fobservability%2Fprometheusrules%2Fcloudwatch-exporter.prometheusrules.yaml) defined for metrics that we monitor through the cloudwatch exporter. An up-to-date list of such alerts can be found in the `openshift-customer-monitoring` namespace file corresponding to the cluster that the [app-sre-observability-production](https://visual-app-interface.devshift.net/namespaces#/services/observability/namespaces/app-sre-observability-production.yml) currently lives on.

The SOP's are a WIP. Currently most alerts are left to be handled by the best interpretation of the on-call SRE.

## Diagnostics

A good place to start is the cloudwatch exporter pod logs. Head to the respective `app-sre-observability[stage|production]` namespace, then look at the pod logs. The pods follow the naming convention `cloudwatch-exporter-<aws-account-name>`

One common issue during a net new exporter setup is misconfigured permissions on the IAM account and/or a missing secret. Check the namespace file, the IAM user being created, and the secret being used.

## Further Documentation

Further documentation on this exporter is available at the [official Github repo](https://github.com/prometheus/cloudwatch_exporter#cloudwatch-exporter)
