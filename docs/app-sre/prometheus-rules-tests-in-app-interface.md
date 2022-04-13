# Prometheus rules tests in app-interface

## Table of contents

* [Introduction](#introduction)
* [The test runner](#the-test-runner)
* [When to write tests](#when-to-write-tests)
* [Notes on writing tests](#notes-on-writing-tests)
* [Running prometheus tests locally](#running-prometheus-tests-locally)
* [Further documentation](#further-documentation)

## Introduction

We rely on Prometheus to generate alerts for our service using expressions that are difficult to test in real world as they are dependent on very specific conditions or that don't do what you expect. Luckily Prometheus developers have recognized this and [unit tests](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/) can be written for Prometheus alert and recording rules.

In app-interface the prometheus rules that have the `/openshift/prometheus-rule-1.yml` schema will be validated using the `promtool check rules` command which will use the tests that have the `/app-interface/prometheus-rule-test-1.yml` schema.  These tests will be run using the `promtool test rules` command. e.g. rules in [cloudwatch-exporter.prometheusrules.yaml](resources/observability/cloudwatch-exporter/prometheusrules/cloudwatch-exporter.prometheusrules.yaml) are tested in the [cloudwatch-exporter.prometheusrulestests.yaml](resources/observability/cloudwatch-exporter/prometheusrules/cloudwatch-exporter.prometheusrulestests.yaml) file.

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

While writing tests, sometimes it is convenient to be able to run tests locally to avoid waiting for them to be run in Jenkins.  You can use the script [`run-prometheus-test.py`](/hack/run-prometheus-test.py) for this matter. Do not try to run things via `promtool` directly as paths in the files do not correspond exactly to app-interface repository.

```
./hack/run-prometheus-test.py -h
usage: run-prometheus-test.py [-h] [-v VARS_FILE] [-p] [-k] test_file

positional arguments:
  test_file             Prometheus test file

optional arguments:
  -h, --help            show this help message and exit
  -v VARS_FILE, --vars-file VARS_FILE
                        File with variables in yaml format
  -p, --pretty-print    Pretty print prometheus test errors
  -k, --keep-temp-files
                        Pretty print prometheus test errors
```

In app-interface, [openshiftResouces](/README.md#manage-openshift-resources-via-app-interface-openshiftnamespace-1yml) can be straight yamls containing the openshift resources or jinja templates with variables that will be expanded with the `variables` set in the namespace file. If your prometheus rule file is a jinja template, your test will need to be a template too. When running the tests locally, we'll need to pass manually the variables that are usually passed via the namespace file definition.

## Requirements

You need `promtool` installed. You can download it from https://github.com/prometheus/prometheus/releases

You need pyyaml and jinja2 modules in Python

## Example 1: non-templated rule file

From app-interface root:

```
$ ./hack/run-prometheus-test.py resources/observability/prometheusrules/app-sre-contract.prometheusrulestests.yaml
Checking /var/folders/dx/y5_klhc1187gnzzmyb4pswb40000gn/T/tmpnp8xcg66
  SUCCESS: 2 rules found

Unit Testing:  /var/folders/dx/y5_klhc1187gnzzmyb4pswb40000gn/T/tmp2ahrj8x0
  SUCCESS
```

# Example 2: templated rule file

If we want to test a file such as [`hive-production-capacity.prometheusrules-test.yaml`](resources/observability/prometheusrules/hive-production-capacity.prometheusrules-test.yaml) that is templated, you will need to pass the variables from the resource file in a separate yaml. We first create a `variables.yaml` file that contains the jinja2 variables:

```
variables:
  appsre_env: production
  max_clusters_per_shard: 500
  grafana_datasource: app-sre-prod-01-prometheus
```

and then you can run your tests

```
$ ./hack/run-prometheus-test.py -v variables.yaml resources/observability/prometheusrules/hive-production-capacity.prometheusrules-test.yaml
Checking /var/folders/dx/y5_klhc1187gnzzmyb4pswb40000gn/T/tmpi58b5vwn
  SUCCESS: 3 rules found

Unit Testing:  /var/folders/dx/y5_klhc1187gnzzmyb4pswb40000gn/T/tmpwmuo68tq
  SUCCESS
```

## Further documentation

Writing tests can be difficult at the beginning. This [article](https://www.robustperception.io/unit-testing-rules-with-prometheus) is a nicer start than the official documentation.
