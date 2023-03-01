# Prometheus rules tests in app-interface

## Table of contents

[TOC]

## Introduction

We rely on Prometheus to generate alerts for our service using expressions that are difficult to test in real world as they are dependent on very specific conditions or that don't do what you expect. Luckily Prometheus developers have recognized this and [unit tests](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/) can be written for Prometheus alert and recording rules.

In app-interface the prometheus rules that have the `/openshift/prometheus-rule-1.yml` schema will be validated using the `promtool check rules` command which will use the tests that have the `/app-interface/prometheus-rule-test-1.yml` schema. Note that prometheus rules need to be referenced from a namespace that has the `/openshift/namespace-1.yml` schema.

These tests will be run using the `promtool test rules` command. e.g. rules in [cloudwatch-exporter.prometheusrules.yaml](resources/observability/cloudwatch-exporter/prometheusrules/cloudwatch-exporter.prometheusrules.yaml) are tested in the [cloudwatch-exporter-templated.prometheusrulestests.yaml](resources/observability/cloudwatch-exporter/prometheusrules/cloudwatch-exporter-templated.prometheusrulestests.yaml) file for namespaces [app-sre-prod-01](data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml) and [app-sre-stage-01](data/services/observability/namespaces/openshift-customer-monitoring.app-sre-stage-01.yml).

## The test runner

The integration running the tests is a wrapper on top of `promtool`. It looks for resources with the `/app-interface/prometheus-rule-test-1.yml` schema and the namespaces from where they are referenced. A few notes about how it works:

* Since prometheus rules can be templates, prometheus tests need to be templates (`extracurlyjinja2` type). The variables the template will expand are the same for the prometheus rule it tests.
* Tests will be run for every namespace where the rules are defined. This is needed as rules can have a different shape from one namespace to other.
* The prometheus test schema allows for multiple rule files in a test. This complicated the code to run the tests a lot so we allow for one test rule per test file.

## When to write tests

In general, any alerts that are to be handled by app-sre (`high` and `critical` severity) should always come with tests associated to them, but there are exceptions. Let's explain them.

Tests are completely isolated from the real world. The series used are completely synthetic and defined from the test itself. Since writing Prometheus tests is not a trivial exercise (especially if it is the first time), app-sre will only ask for tests to be created when they have an added value, e.g. testing non-trivial PromQL queries, recorded rules, etc...

If your alert rule contains trivial PromQL (e.g. `up{foo="bar"} > 0`), writing tests is not very useful as it won't really guarantee that rules will actually work as expected in real life. The test is a self-contained artifact, meaning it could be perfectly valid and contain a non-existing label. That's why app-sre won't ask for such alerts to come with a test associated.

Prometheus rules that won't be handled by app-sre will always benefit from tests, but those are not required. If an existing alert that didn't have test is modified in such a way that it reaches app-sre it will need tests if is complex enough to benefit from the effort of writing them.

## Notes on writing tests

* Since tests are based on synthetic series, those can be completely meaningless if not crafted with care. Use always metrics with real labels that come from real prometheus queries.
* It is very useful to understand the different prometheus [metric types](https://prometheus.io/docs/concepts/metric_types/) to create the tests series.
* If your alerts are based on recording rules then do not write tests using the recorded series.  Instead always use the original metrics or you won't be testing the complete setup.
* Make sure that your tests contain cases that cover the scenario of alerts being triggered and alerts not being triggered

## Running prometheus tests locally

While writing tests, sometimes it is convenient to be able to run tests locally to avoid waiting for them to be run in Jenkins.  You can use the qontract-cli `run-prometheus-test` command for this matter. Do not try to run things via `promtool` directly as paths in the files do not correspond exactly to app-interface repository.

```
Usage: qontract-cli run-prometheus-test [OPTIONS] PATH CLUSTER

  Run prometheus tests in PATH loading associated rules from CLUSTER.

Options:
  -n, --namespace TEXT            Cluster namespace where the rules are
                                  deployed. It defaults to openshift-customer-
                                  monitoring.

  -s, --secret-reader [config|vault]
                                  Location to read secrets.
  --help                          Show this message and exit.
```

### Requirements

#### qontract-reconcile

In order to use this tool, the easiest option is to use pip to install `qontract-reconcile`.

```
$ pip install --user qontract-reconcile --upgrade
```

If you need to have multiple Python versions installed locally, you can use projects such as [pyenv](https://github.com/pyenv/pyenv).

#### promtool

and `promtool` version 2.33.3. You can find as part of the Prometheus [distribution](https://github.com/prometheus/prometheus/releases/tag/v2.33.3).

#### configuration file

Prior to running the commands you will need to create the following `config.promtool.toml` file:

```
[graphql]
server = "http://localhost:4000/graphql"
```

### Example

* From `app-interface` root start a local server that will load the repository data:

  ```
  make server
  ```

* In a different terminal, from the directory where you have cloned `qontract-reconcile`:

  ```
  $ qontract-cli --config config.promtool.toml run-prometheus-test -s config \
    resources/observability/prometheusrules/app-interface-production.prometheusrulestests.yaml  \
    app-sre-prod-01
  Unit Testing:  /var/folders/dx/y5_klhc1187gnzzmyb4pswb40000gn/T/tmp7kj8agy1
    SUCCESS
  ```

**IMPORTANT**: The local server loads the graph based on the state of the repository when the server is started. Thus, you must *restart* the server to make it reflect any local edits to the tests or rules files. In order to do it, just hit Ctrl-C in the terminal where you're runnning the local server and start it again via `make server`.

### A note on secrets

The previous example assumes that any potential secret will be searched locally in the `config.promtool.toml`. In case that a local secret is needed to be configured, you will receive an error message about it. Please read [this doc](/docs/app-sre/alert-to-receiver.md#secrets-reader) in order to know how to add the relevant bits to your configuration.

## Further documentation

Writing tests can be difficult at the beginning. The articles [here](https://www.robustperception.io/unit-testing-rules-with-prometheus) and [here](https://howardburgess.github.io/prometheus-unit-testing/#/) are a nicer start than the official documentation.
