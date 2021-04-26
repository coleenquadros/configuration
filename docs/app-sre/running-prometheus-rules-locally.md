# Running prometheus tests locally

You can use the script [`run-prometheus-test.py`](/hack/run-prometheus-test.py) for this matter. Do not try to run things via `promtool` as paths in the files do not correspond exactly to app-interface repository.

```
./hack/run-prometheus-test.py -h
usage: run-prometheus-test.py [-h] [-v VARS_FILE] [-p] test_file

positional arguments:
  test_file             Prometheus test file

optional arguments:
  -h, --help            show this help message and exit
  -v VARS_FILE, --vars-file VARS_FILE
                        File with variables in yaml format
  -p, --pretty-print    Pretty print prometheus test errors
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
