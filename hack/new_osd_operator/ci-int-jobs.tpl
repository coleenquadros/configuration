---
$schema: /dependencies/jenkins-config-1.yml

labels:
  service: osd-operators

name: ci-int-osd-operators-{operator_name}-jobs

description: ''

instance:
  $ref: /dependencies/ci-int/ci-int.yml

type: jobs

config:
- project:
    name: {operator_name}
    label: osd-operators
    node: osd-operators
    gh_org: openshift
    gh_repo: {operator_name}
    quay_org: app-sre
    build_deploy_script_path: './hack/app_sre_build_deploy.sh'
    jobs:
    - 'gh-build-master':
        display_name: {operator_name} build master
