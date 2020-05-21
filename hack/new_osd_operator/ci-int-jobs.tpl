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
    kube_cluster: hive-stage
    kube_namespace: {operator_name}
    saasherder_context: {operator_name}
    saasherder_services: {operator_name}
    saas_git: https://gitlab.cee.redhat.com/service/saas-osd-operators.git
    build_deploy_script_path: './hack/app_sre_build_deploy.sh'
    disable_saasherder_delete: true
    disable_saasherder_validate: true
    jobs:
    - 'gh-build-master':
        ssh_ci_ext: yes
        display_name: {operator_name} build master
    - 'gh-build-master-with-upstream':
        saas_env: integration
        kube_cluster: hive-integration
        upstream: openshift-{operator_name}-gh-build-master
        display_name: {operator_name} build master hive-integration
        build_deploy_script_path: 'true'
        disable: true

- project:
    name: {operator_name}-saas
    label: osd-operators
    node: osd-operators
    gl_group: service
    gl_project: saas-osd-operators
    kube_cluster: hive-production
    kube_namespace: {operator_name}
    saasherder_context: {operator_name}
    image_pattern: '^quay\.io/app-sre/'
    quay_org: app-sre
    ssh_ci_ext: yes
    disable_saasherder_delete: true
    disable_saasherder_validate: true
    jobs:
    - 'saas-deploy':
        display_name: {operator_name} saas deploy
    - 'saas-pr-check':
        display_name: {operator_name} saas pr-check
