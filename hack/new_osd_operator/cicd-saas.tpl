---
$schema: /app-sre/saas-file-1.yml

labels:
  service: osd-operators

name: saas-{operator_name}
description: SaaS tracking file for {operator_name}

app:
  $ref: /services/osd-operators/app.yml

instance:
  $ref: /dependencies/ci-int/ci-int.yml

slack:
  workspace:
    $ref: /dependencies/slack/coreos.yml
  channel: team-srep-info

managedResourceTypes: {managed_resource_types}

imagePatterns:
- quay.io/app-sre/{operator_name}-registry

resourceTemplates: []
