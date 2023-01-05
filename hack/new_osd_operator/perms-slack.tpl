---
$schema: /access/permission-1.yml

labels: {{}}

name: {operator_name}-coreos-slack
description: SREP {operator_name} owners (managed via app-interface)

service: slack-usergroup
handle: {operator_name}

workspace:
  $ref: /dependencies/slack/redhat-internal.yml

ownersFromRepos:
  - https://github.com/openshift/{operator_name}

channels:
- sd-sre-platform
- sre-operators
- team-srep-alert
