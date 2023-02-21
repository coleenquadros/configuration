---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: app-sre-event-router
description: namespace to deploy event-router

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/observability/app.yml

environment:
  $ref: /products/app-sre/environments/{environment}.yml
