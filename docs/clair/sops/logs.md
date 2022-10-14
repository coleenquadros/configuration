# Clair v4 - Cloudwatch logs

## Steps
Before the migration off the CLO AddOn:
* Log into AppSRE AWS logging account: https://744086762512.signin.aws.amazon.com/console 
* Switch roles to clair-cluster (initially lookup your user [here](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ocm-aws-infrastructure-access-switch-role-links.md) and read-only for clairp01ue1 and click link)
* Browse to cloudwatch: https://console.aws.amazon.com/cloudwatch/home
* Select logging group `clairp01ue1-4lbp9.application`

After that migration:
* Log into AppSRE AWS logging account: https://744086762512.signin.aws.amazon.com/console 
* Browse to cloudwatch: https://console.aws.amazon.com/cloudwatch/home
* Select logging group `clairp01ue1.<namespace>`


## Example Queries

### Indexer Errors
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter level = "error"
| sort @timestamp desc
```

### Manifests Indexed
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "indexer"
| filter message like "manifest successfully scanned"
| sort @timestamp desc
```

### Notifier Errors
```
fields @timestamp, message
| filter kubernetes.namespace_name = "clair-production"
| filter kubernetes.labels.service = "notifier"
| filter level = "error"
| sort @timestamp desc
| limit 200
```
