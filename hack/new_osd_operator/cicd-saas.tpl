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

resourceTemplates:
- name: {operator_name}
  url: https://github.com/openshift/{operator_name}
  path: /hack/olm-registry/olm-artifacts-template.yaml
  parameters:
    REGISTRY_IMG: quay.io/app-sre/{operator_name}-registry
  targets:
  - namespace:
      $ref: /services/osd-operators/namespaces/hive-integration-cluster-scope.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  - namespace:
      $ref: /services/osd-operators/namespaces/hivei01ue1/cluster-scope.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  - namespace:
      $ref: /services/osd-operators/namespaces/hive-stage-cluster-scope.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  - namespace:
      $ref: /services/osd-operators/namespaces/hive-stage-01/cluster-scope.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  - namespace:
      $ref: /services/osd-operators/namespaces/hives02ue1/cluster-scope.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  - namespace:
      $ref: /services/osd-operators/namespaces/ssotest01ue1/cluster-scope.yml
    ref: master
    upstream: openshift-{operator_name}-gh-build-master
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/hive-production-cluster-scope.yml
  #   ref: {commit}
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/hivep01ue1/cluster-scope.yml
  #   ref: {commit}
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/hivep02ue1/cluster-scope.yml
  #   ref: {commit}
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/hivep03uw1/cluster-scope.yml
  #   ref: {commit}
  # - namespace:
  #     $ref: /services/osd-operators/namespaces/hivep04ew2/cluster-scope.yml
  #   ref: {commit}