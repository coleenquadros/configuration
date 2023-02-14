# Prometheus rules tester supports cluster-name option

## Tracking JIRA ticket

[APPSRE-7018](https://issues.redhat.com/browse/APPSRE-7018)

## Problem statement

As part of our on-going effort to reduce the time the Merge Request builds, we are running the integrations checks only in the affected shards. This means in some cases defining the AWS account that is affected (`terraform-resources`) and in other cases, the cluster (e.g. `openshift-resources`).

`prometheus-rules-tester` is a very slow integration since it performs discovery on all the clusters' openshift resources to load the rules that are needed to run tests. Being able to run it in a single cluster can reduce the time to execute up to four times, depending on the cluster chosen.

The integration in its current shape advertises a `--cluster-name` option that is currently broken beyond repair. It fails in [this check](https://github.com/app-sre/qontract-reconcile/blob/3903f6e1effe31dfc190cac1ed553af768b0c417/reconcile/prometheus_rules_tester.py#L343-L349) where it tries to check that the rule file that is used in the Prometheus rule test exists and it is used in a namespace. The latter is very important as a Prometheus rule file, being a resource, can be a Jinja template, hence we need the corresponding variables defined in a namespace file. The integration breaks when there are rules that are filtered out due to the `--cluster-name option`. Since all tests are considered as they are not linked to anything else than a rule we cannot know if the rules used from the tests do not exist or they are just used in different clusters.

There's no way to make the current integration work with `--cluster-name` without major changes, as we need to be able to link a Prometheus test not only with a rule but with a cluster so that we can know which ones to consider.

As a by-product of the refactoring work and in the spirit of reducing the build time, we should aim to make the integration faster using multiprocessing instead of threads. We have conducted a few experiments that support this idea in https://issues.redhat.com/browse/APPSRE-5699 and in the context of the [current work](https://github.com/app-sre/sretoolbox/pull/89) to make [`sretoolbox`](https://github.com/app-sre/sretoolbox) support multiprocessing using the same kind of API as we have with threads.

## Goals

* Make the integration support `cluster-name`.
* Experiment with multiprocessing instead of threading to make the integration run as fast as possible.
* Keep the current `target_cluster` functionality. See https://issues.redhat.com/browse/APPSRE-6316 for details.
* Make the changes in a backwards compatible way so that we can do a progressive rollout.

## Non-goals

* Remove the limitation of one rule file per test from the current implementation.

## Proposal

The proposal is to add a new `openshift-resources` provider that is dedicated to Prometheus rules files and has a reference to the tests associated with it. For example:

```yaml
- provider: prometheus-rule
  type: extracurlyjinja2
  path: /observability/prometheusrules/aws-resources-privatelink.prometheusrules.yaml.j2
  enable_query_support: true
  variables:
    job_stage: aws-resource-exporter-osd-privatelink-prod
    environment: prod
    severity: high
  tests:
  - /observability/prometheusrules/aws-resources-privatelink.prometheusrulestests.yaml
```

The associated test files would get the `rule_files` and `target_cluster` removed from them as they can be determined from the namespace file.

The only downside of this approach is that we have to state explicitly in which namespaces we want the tests to be run, but the existence of the `target_cluster` key leads us to believe that this can be actually a feature.

## Alternatives considered

We can create a new data object that references prometheus tests and its associated namespaces. The `provider` pattern has been successful enough to avoid adding a new object that makes the coupling between rules and tests less obvious.

## Milestones

* Add the schema changes that will allow the rules to not define `rule_files`.
* Deploy the new integration.
* Migrate the current tests to the new system.
* Remove the old integration.
* Remove the not needed schema fields.

## Acknowledgements

Thanks to @goberlec for the discussions and suggestions that have led to this design doc.
