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

managedResourceTypes:
- CatalogSource
- OperatorGroup
- Subscription

imagePatterns:
- quay.io/app-sre/{operator_name}-registry

resourceTemplates:
- name: {operator_name}
  url: https://github.com/openshift/{operator_name}
  path: /hack/olm-registry/olm-artifacts-template.yaml
  parameters:
    REGISTRY_IMG: quay.io/app-sre/{operator_name}-registry
  targets:
  - namespace:
      $ref: /services/osd-operators/namespaces/{operator_name}-integration.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/{operator_name}-stage.yml
  #   ref: master
  #   upstream: openshift-{operator_name}-gh-build-master
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/{operator_name}-production.yml
  #   ref: 935f039cb64f208bc70fbea17631cdca086a2b81