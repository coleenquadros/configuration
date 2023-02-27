Namespace Selector for SaaS Files
---
Table of contents:

[toc]


## Author/date
Christian Assing - February 2023

## Tracking JIRA
[APPSRE-7124](https://issues.redhat.com/browse/APPSRE-7124)

## Problem Statement

The list of namespaces where the resources of a saas file get deployed is static (`resourceTemplates[].targets`).
While this is fine for most use cases and has been in use for many years, there are also many other cases where a
dynamic namespaces list would be handy and obsoletes manual work. E.g.,

* [openshift-cert-manager](https://gitlab.cee.redhat.com/service/app-interface/-/blob/db13ce34e4b425cac5e7436e2d7ee983db6bf7b7/data/services/app-sre/cicd/ci-int/saas-openshift-cert-manager-routes.yaml#L42):
  The `openshift-cert-manager` namespace of each new cluster must be added manually
* [Prometheus per cluster](https://gitlab.cee.redhat.com/service/app-interface/-/blob/db13ce34e4b425cac5e7436e2d7ee983db6bf7b7/data/services/observability/cicd/saas/saas-observability-per-cluster.yaml#L42)
  The `openshift-customer-monitoring` namespace of each new cluster must be added manually
* Gabi, CSO, and DVO are following the same pattern
* [Hive shards](https://gitlab.cee.redhat.com/service/app-interface/-/blob/edd1695663551bddae70defe31aa62fbb96ef78b/data/services/addons/cicd/ci-int/saas-mt-PagerDutyIntegration.yaml#L49): Tenants want to deploy the same on all hive shards in a given environment.
* Deploy skupper monitoring in each skupper-enabled namespace (`skupperSite` attribute)


## Goal

An App-Interface user should be able to define dynamic namespace targets for `resourceTemplates` in a saas file as an additional
option to the static list of namespaces. The dynamic namespace targets must support the same features as the static list.

## Non-objectives

N/A

## Proposal

Introduce a dynamic namespace selector attribute for a saas file target.
The selector should be able to select namespaces based on various criteria.

For example, select namespaces based on the following:

* namespace name (e.g., `openshift-customer-monitoring`)
* namespace labels (e.g., `hive: prod`)
* specific namespace attributes (e.g., `skupperSite`)

## Details

### Implementation

Whereas the behavior of all `resourceTemplages[].targets` features (e.g., `parameters`, `upstream`, `image`) are straightforward for the dynamic namespace selector, the behavior of the `promotion` attribute needs to be defined:

* `promotion.subscribe`: Trigger the deployment on all selected targets as soon as the message arrives.
* `promotion.publish`: Publish the message(s) after successful deployments of the selected namespaces.

#### Schema

Enhance the saas file target schema (`/app-sre/saas-file-target-1.yml`) to support a dynamic namespace selector, and in addition,
`parameters` and `secretParameters` must accept Jinja templates to evolve more flexibility.

```yaml
$schema: /app-sre/saas-file-2.yml

...

resourceTemplates:
- name: example
  url: https://github.com/app-sre/example
  path: /openshift/deploy.yaml
  parameters:
    PARAMETER_1: "foobar"
  targets:
  # static namespace target
  - provider: static  # optional, default: static
    namespace:
      $ref: <namespace-ref>
    ref: main
    parameters:
      PARAMETER_2: "something-else"

  # dynamic namespaces via a namespace selector
  - provider: dynamic
    namespaceSelector:
      jsonPathSelectors:
        include:
        - <json path query>
        exclude:
        - <json path query>
    ref: main

    parameters:
      PARAMETER_2: "something-else"
      PARAMETER_3: "{{{ jinja_variable }}}"

    secretParameters:
    - name: ENV_KEY_NAME
      secret:
        path: path/{{{ resource.namespace.labels.environment }}}/secret
        field: field-name
```

* `provider`: Optional attribute to select the target type. The default is `static` for static targets and `dynamic` for the new dynamic targets.
* `namespace` and `namespaceSelector` are mutually exclusive. Only one of them can be defined.
* `namespaceSelector.jsonPathSelectors`: The `jsonPathSelectors.include` and `jsonPathSelectors.exclude` are evaluated
  against all App-Interface namespaces. The `include` queries are evaluated first, and the namespaces from `exclude`
  queries are removed from the result. The queries are `or` combined.

  :warning: **Attention**: Due to the nature of this feature, the `jsonPathSelectors` must be used with care.
  **No security measurements** are in place to prevent a user from selecting all namespaces in App-Interface or deploying
  to a namespace where the user has no permissions.
* `targets.parameters` and `targets.secretParameters` values can include Jinja template variables using the
  extra curly syntax (`{{{ jinja_var }}}`). The Jinja template context contains a `resource.namespace` object representing the selected namespace. E.g.,
  ```yaml
  ...
  parameters:
    ENVIRONMENT: '{{{ resource.namespace.labels.environment }}}'
    CLUSTER_LABEL: '{{{ resource.namespace.cluster.name }}}'
  secretParameters:
  - name: CLIENT_ID
    secret:
      path: foobar/my-app/{{{ resource.namespace.labels.environment }}}/another-app-api-access
      field: client-id
      version: 2
  - name: CLIENT_KEY
    secret:
      path: foobar/my-app/{{{ resource.namespace.labels.environment }}}/another-app-api-access
      field: client-key
      version: 2
  ```

#### Sass file trigger

A saas file must be triggered when a namespace is added or removed from the dynamic namespace selector or changed.
To achieve this, we have to introduce a new `openshift-saas-deploy-trigger` qontract-reconcile integration that listens
to changes in App-Interface and triggers the saas file deployment.

#### Saas file deployment

For the deployment part of a saas file, the dynamic namespace selector must be implemented and considered in the [reconcile.utils.saasherder](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/utils/saasherder.py). The idea is to resolve all dynamic namespace selectors (`provider: dynamic`) in the [`__init__` method](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/utils/saasherder.py#L182) and replace them with static namespace targets in memory. The rest of the code can remain unchanged.

### Examples

**Prometheus per cluster**

Deploy Prometheus to each cluster in the `openshift-customer-monitoring` namespace and distinguish between staging, dev, and prod clusters.

```yaml
$schema: /app-sre/saas-file-2.yml

name: saas-app-sre-observability-per-cluster
...

resourceTemplates:
- name: prometheus
  path: /openshift/prometheus.template.yaml
  url: https://gitlab.cee.redhat.com/service/app-sre-observability
  parameters:
    VERSION: v2.30.3
    ...
  targets:
  # staging clusters
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name=="openshift-customer-monitoring" & @.environment.labels.type=="stage")]
    ref: master
    parameters:
      CLUSTER_LABEL: "{{{ resource.namespace.cluster.name }}}"
      ENVIRONMENT: staging
      EXTERNAL_URL: https://prometheus.{{{ resource.namespace.cluster.name }}}.devshift.net

  # dev clusters
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name=="openshift-customer-monitoring" & @.environment.labels.type=="dev")]
    ref: master
    parameters:
      CLUSTER_LABEL: "{{{ resource.namespace.cluster.name }}}"
      ENVIRONMENT: dev
      EXTERNAL_URL: https://prometheus.{{{ resource.namespace.cluster.name }}}.devshift.net

  # all non-staging and non-dev clusters
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name=="openshift-customer-monitoring")]
      exclude:
      - namespace[?(@.environment.labels.type=="dev")]
      - namespace[?(@.environment.labels.type=="stage")]
    ref: e2c6ff56d8db618989accdc89c8d8b10e3debf54
    parameters:
      CLUSTER_LABEL: "{{{ resource.namespace.cluster.name }}}"
      ENVIRONMENT: production
      EXTERNAL_URL: https://prometheus.{{{ resource.namespace.cluster.name }}}.devshift.net

```

**Gabi**

Deploy a Gabi instance to all namespaces with a specific `gabi` label.

> :information_source: **Note**:
>
> This for demo puroses only. It would make more sense to introduce a dedicated `gabi` attribute to namespaces to
> configure the to be used RDS instance.


```yaml
$schema: /app-sre/saas-file-2.yml

...

resourceTemplates:
- name: gabi-no-cluster-resources
  url: https://github.com/app-sre/gabi
  path: /openshift/gabi.template.yaml
  parameters:
    SPLUNK_INDEX: rh_app_sre
    OAUTH_PROXY_IMAGE_TAG: 4.10.0
    ENVIRONMENT: production
  targets:
  # AppSRE staging instance
  - namespace:
      $ref: /services/gabi/namespaces/gabi-stage.yml
    ref: main
    upstream:
      instance:
        $ref: /dependencies/ci-ext/ci-ext.yml
      name: app-sre-gabi-gh-build-main
    parameters:
      HOST: gabi-stage.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com
      NAMESPACE: gabi-stage
      AWS_RDS_SECRET_NAME: gabi-stage-rds
      GABI_INSTANCE: gabi-stage
    promotion:
      publish:
      - github-gabi-stage-deploy-success-channel

  # Tenant namespaces
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.label.gabi)]
    ref: 460847c07c64d4fd17db5b10370646c201a66254
    promotion:
      auto: true
      subscribe:
      - github-gabi-stage-post-deploy-tests-success-channel
      promotion_data:
      - channel: github-gabi-stage-post-deploy-tests-success-channel
        data:
        - parent_saas: saas-gabi-post-deploy-tests
          target_config_hash: 4bd3b810e44c224f
          type: parent_saas_config
    parameters:
      HOST: gabi-{{{ resource.namespace.labels.gabi }}}.{{{ resource.namespace.cluster.elbFQDN|replace('elb.', '', 1) }}}
      NAMESPACE: {{{ resource.namespace.name }}}
      AWS_RDS_SECRET_NAME: {{{ resource.namespace.labels.gabi }}}-readonly
      GABI_INSTANCE: gabi-{{{ resource.namespace.labels.gabi }}}
```

**Skupper Monitoring**

Deploy the Skupper monitoring stack to all namespaces with the `skupperSite` attribute and distinguish between stage and production namespaces.

```yaml
$schema: /app-sre/saas-file-2.yml

...

resourceTemplates:
- name: x509-certificate-exporter
  ...
  targets:
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name.skupperSite & @.environment.labels.type=="stage")]
    ref: master
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name.skupperSite)]
      exclude:
      - namespace[?(@.environment.labels.type=="stage")]
    ref: e2c6ff56d8db618989accdc89c8d8b10e3debf54
- name: skupper-exporter
  ...
  targets:
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name.skupperSite & @.environment.labels.type=="stage")]
    ref: master
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.name.skupperSite)]
      exclude:
      - namespace[?(@.environment.labels.type=="stage")]
    ref: e2c6ff56d8db618989accdc89c8d8b10e3debf54
```

**Hive Shards**

Deploy to all hive shard namespaces of a given environment.

```yaml
$schema: /app-sre/saas-file-2.yml

...

resourceTemplates:
- name: managed-tenants-stage
  url: https://gitlab.cee.redhat.com/service/managed-tenants-manifests
  path: /stage
  provider: directory
  targets:
  # all hive shards in stage
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.cluster.externalConfiguration.labels."ext-managed.openshift.io/hive-shard"=="true" & @.environment.labels.type=="stage")]
    ref: main
  # all hive shards in production
- name: managed-tenants-production
  url: https://gitlab.cee.redhat.com/service/managed-tenants-manifests
  path: /production
  provider: directory
  targets:
  - provider: dynamic
    namespaceSelector:
      include:
      - namespace[?(@.cluster.externalConfiguration.labels."ext-managed.openshift.io/hive-shard"=="true" & @.environment.labels.type=="production")]
    ref: main
```

### Test Namespace Selector

Use the CLI command `saas-namespace-selector` to verify the namespace selector and review the selected namespace. It shows the complete target list with all selected namespaces and resolved Jinja variables. E.g., for the `prometheus` example above:

```bash
$ qontract-cli --config config.toml saas-namespace-selector --app-name app-sre-observability --saas-name saas-app-sre-observability-per-cluster

targets:
...
- namespace:
    name: openshift-customer-monitoring
    cluster:
      name: app-sre-stage-01
  ref: master
  parameters:
    CLUSTER_LABEL: app-sre-stage-01
    ENVIRONMENT: staging
    EXTERNAL_URL: https://prometheus.app-sre-stage-01.devshift.net

- namespace:
    name: openshift-customer-monitoring
    cluster:
      name: app-sre-prod-01
  ref: e2c6ff56d8db618989accdc89c8d8b10e3debf54
  parameters:
    CLUSTER_LABEL: app-sre-prod-01
    ENVIRONMENT: production
    EXTERNAL_URL: https://prometheus.app-sre-prod-01.devshift.net

...
```

## Limitations and Open Topics

N/A

## Milestones

* [ ] AppSRE team approval
* [ ] Implementation

## Links

* [Continuous Delivery in App-interface](../continuous-delivery-in-app-interface.md)
