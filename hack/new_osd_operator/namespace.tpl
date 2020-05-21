---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: {operator_name}
description: {level} namespace for {operator_name}

cluster:
  $ref: /openshift/hive-{level}/cluster.yml

app:
  $ref: /services/osd-operators/app.yml

environment:
  $ref: /products/osdv4/environments/{level}.yml

networkPoliciesAllow:
- $ref: /services/osd-operators/namespaces/olm-{level}.yml

managedRoles: true

managedResourceTypes:
- Secret
- ConfigMap
