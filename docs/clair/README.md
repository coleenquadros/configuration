# Standard operating procedures for Clair v4

## Clair SOPs

- [Clair Application SOPs](sops/README.md)

## Clair Dependencies

- [RDS (Databases)](services/database.md)


## Clair Architecture Doc

- [Clair Architecture Doc](clair.md)

## Clair Configuration

Configuration documentation for Clair can be found [here](https://pkg.go.dev/github.com/quay/clair/config).

| Environment | Config |
| --- | --- |
|Stage|[ConfigSecret](../../resources/clair/stage/clair-config-secret.yaml)|
|Production|[ConfigSecret](../../resources/clair/production/clair-config-secret.yaml)|


## Clair Observability

| Environment | Dashboard |
| --- | --- |
|Stage|[Grafana](https://grafana.app-sre.devshift.net/d/I1JBFlRnz/clair-v4?orgId=1&var-rate=1m&var-dbquantile=0.95&var-apiquantile=0.20&var-datasource=app-sre-stage-01-prometheus)|
|Production|[Grafana](https://grafana.app-sre.devshift.net/d/I1JBFlRnz/clair-v4?orgId=1&var-rate=1m&var-dbquantile=0.95&var-apiquantile=0.20&var-datasource=clairp01ue1-prometheus)|


## Clair Logs

More information for how to access the logs is available [here](../../FAQ.md#get-access-to-cluster-logs-via-log-forwarding)

| Environment | Dashboard |
| --- | --- |
|Stage|[Cloudwatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights) TODO: No stage logs currently|
|Production|[Cloudwatch](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D$257E$2528end$257E0$257Estart$257E-3600$257EtimeType$257E$2527RELATIVE$257Eunit$257E$2527seconds$257EeditorString$257E$2527fields*20*40timestamp*2c*20message*0a*7c*20sort*20*40timestamp*20desc$257EisLiveTail$257Efalse$257EqueryId$257E$25276acd1ca6-d748-4f9a-8bb7-cbcc4b738bee$257Esource$257E$2528$257E$2527clairp01ue1-4lbp9.application$2529$2529)|

## Clair AWS Accounts

 Sign in via https://744086762512.signin.aws.amazon.com/console and add an alias to the following accounts: [switch roles here](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ocm-aws-infrastructure-access-switch-role-links.md)

| Environment | Account |
| --- | --- |
|Stage|262100652550|
|Production|587301633814|

## Clair Openshift Clusters

| Environment | Console |
| --- | --- |
|Stage|[Openshift Console](https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/cluster/projects/clair-stage)|
|Production|[Openshift Console](https://console-openshift-console.apps.clairp01ue1.qtmm.p1.openshiftapps.com/k8s/cluster/projects/clair-production)|

