---
$schema: /openshift/namespace-1.yml

labels: {label}

name: {operator_name}
description: namespace for {operator_name}

cluster:
  $ref: /openshift/{hive_instance_name}/cluster.yml

app:
  $ref: /services/osd-operators/app.yml

environment:
  $ref: /products/osdv4/environments/{environment}.yml

networkPoliciesAllow:
- $ref: /openshift/{hive_instance_name}/namespaces/openshift-operator-lifecycle-manager.yml
- $ref: /services/observability/namespaces/openshift-customer-monitoring.{hive_instance_name}.yml

managedRoles: true

# managedResourceTypes:
# ...
#
# sharedResources:
# ...
#
# openshiftResources:
# ...
