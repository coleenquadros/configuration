# RDS Exporter

## Use case

App-SRE currently uses the RDS exporter to monitor and alert on our AWS RDS database resources.

We use the [RDS enhanced metrics exporter](https://github.com/app-sre/rds-enhanced-metrics-exporter) image built from the official [Percona RDS exporter](https://github.com/percona/rds_exporter) 

## Deployment

The RDS exporter is deployed under the app-sre-observability suite of services. We create a new exporter deployment for each AWS account we monitor, and deploy all the exporters centrally in the [app-sre-observability-production namespace](https://visual-app-interface.devshift.net/namespaces#/services/observability/namespaces/app-sre-observability-production.yml)

The RDS exporter requires an IAM user with `AmazonRDSReadOnlyAccess` and `CloudWatchReadOnlyAccess` added to it.

The RDS exporter is complemented by our own [aws-resource-exporter](https://github.com/app-sre/aws-resource-exporter) project and we should make sure we deploy both together.

## Alerts

We have a [set of standard alerts](https://gitlab.cee.redhat.com/service/app-interface/blob/81116a131e0587898c56126c75f9db7981adc73d/resources%2Fobservability%2Fprometheusrules%2Fcloudwatch-exporter.prometheusrules.yaml) defined for metrics that we monitor through the cloudwatch exporter. An up-to-date list of such alerts can be found in the `openshift-customer-monitoring` namespace file corresponding to the cluster that the [app-sre-observability-production](https://visual-app-interface.devshift.net/namespaces#/services/observability/namespaces/app-sre-observability-production.yml) currently lives on.

The SOP's are a WIP. Currently most alerts are left to be handled by the best interpretation of the on-call SRE.

## Diagnostics

A good place to start is the RDS exporter pod logs. Head to the respective `app-sre-observability[stage|production]` namespace, then look at the pod logs. The pods follow the naming convention `rds-exporter-*`

One common issue during a net new exporter setup is misconfigured permissions on the IAM account and/or a missing secret. Check the namespace file, the IAM user being created, and the secret being used.

## Further Documentation

Further documentation on this exporter is available at the [official Github repo](https://github.com/percona/rds_exporter)
