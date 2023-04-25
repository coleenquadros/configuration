
# Alert to receiver discovery

[toc]

The Alertmanager routing tree in app-interface is a large beast and it is sometimes quite hard to really understand where a certain alert will finally go. The `amtool config routes test` command can be used to test the routing tree against certain alert labels. In order to make it easy to work with app-interface's Alertmanager configuration and the fact that many of the prometheus rules are actually jinja templates, we have created a `qontract-cli` command that conveniently wraps `amtool`:

```
$ qontract-cli --config config.local.toml alert-to-receiver --help
Usage: qontract-cli alert-to-receiver [OPTIONS] CLUSTER NAMESPACE RULES_PATH

Options:
  -a, --alert-name TEXT           Alert name in RULES_PATH. Receivers for all
                                  alerts will be returned if not specified.
  -c, --alertmanager-secret-path TEXT
                                  Alert manager secret path.
  -n, --alertmanager-namespace TEXT
                                  Alertmanager namespace.
  -k, --alertmanager-secret-key TEXT
                                  Alertmanager config key in secret.
  -s, --secret-reader [config|vault]
                                  Location to read secrets.
  -l, --additional-label TEXT     Additional label in key=value format. It can
                                  be specified multiple times. If the same
                                  label is defined in the alert, the
                                  additional label will have precedence.
  --help                          Show this message and exit.
```

## Installation

In order to use this tool, the easiest option is to use pip to install `qontract-reconcile`.

```
$ pip install --user qontract-reconcile --upgrade --pre
```

and `amtool` version 0.24. You can find as part of the Alertmanager [distribution](https://github.com/prometheus/alertmanager/releases/tag/v0.24.0).

## Usage

### qontract-server

The tool uses qontract-server to get the Alertmanager configuration and the rules file and the potential template values it may have. The easiest way is to run it locally from an app-interface repository:

```
$ git clone https://gitlab.cee.redhat.com/service/app-interface.git
$ cd app-interface
$ make server
```

Note that this runs a foreground process that produces log output, so you may wish to run it in a dedicated terminal window. You can send `SIGINT` to the server process (e.g. via `Ctrl-C`) to shut it down.

This is also interesting in terms of [testing changes locally](#testing-changes-locally) before sending a MR.

### Secrets Reader

The tool uses the [Alertmanager configuration](/resources/observability/alertmanager/alertmanager-instance.secret.yaml) that is installed in every AppSRE cluster. That configuration needs access to some Vault secrets that are not used in the routing tree, so for those that don't have access to Vault, the best (and certainly faster) option is to the `--secret-reader config` option that adds fake values to certain secrets in the Alertmanager configuration. The following `config.local.toml` should get the majority of cases covered:

```
[graphql]
server = "http://localhost:4000/graphql"

[app-sre.creds.smtp]
username = "username"
password = "password"
server = "server"
port = 625

[app-sre.integrations-input.alertmanager-integration]
slack_api_url = "https://slack_api_url"
pagerduty_appsre_service_key = "pagerduty_appsre_service_key"
pagerduty_cs_sre_service_key = "pagerduty_cs_sre_service_key"
pagerduty_appsre_fts_only_service_key = "pagerduty_appsre_fts_only_service_key"
pagerduty_cloud_redhat_com_service_key = "pagerduty_cloud_redhat_com_service_key"
pagerduty_telemeter_dev_service_key = "pagerduty_telemeter_dev_service_key"
pagerduty_srep_service_key = "pagerduty_srep_service_key"
pagerduty_serviceregistry_slo_service_key = "pagerduty_serviceregistry_slo_service_key"
pagerduty_rhacs_managed_services_service_key = "pagerduty_rhacs_managed_services_service_key"
deadmanssnitch-centralci-url = "https://deadmanssnitch-centralci-url"
deadmanssnitch-quay-builder-url = "https://deadmanssnitch-quay-builder-url"
deadmanssnitch-ci-ext-url = "https://deadmanssnitch-ci-ext-url"
deadmanssnitch-app-sre-prod-01-url = "https://deadmanssnitch-app-sre-prod-01-url"
deadmanssnitch-app-sre-prod-04-url = "https://deadmanssnitch-app-sre-prod-04-url"
deadmanssnitch-app-sre-stage-01-url = "https://deadmanssnitch-app-sre-stage-01-url"
deadmanssnitch-appsrep05ue1-url = "https://deadmanssnitch-appsrep05ue1-url"
deadmanssnitch-appsrep06ue2-url = "https://deadmanssnitch-appsrep06ue2-url"
deadmanssnitch-appsres03ue1-url = "https://deadmanssnitch-appsres03ue1-url"
deadmanssnitch-appsres04ue2-url = "https://deadmanssnitch-appsres04ue2-url"
deadmanssnitch-clairp01ue1-url = "https://deadmanssnitch-clairp01ue1-url"
deadmanssnitch-crcp01ue1-url = "https://deadmanssnitch-crcp01ue1-url"
deadmanssnitch-crcs02ue1-url = "https://deadmanssnitch-crcs02ue1-url"
deadmanssnitch-datahub-psi-url = "https://deadmanssnitch-datahub-psi-url"
deadmanssnitch-hive-stage-01-url = "https://deadmanssnitch-hive-stage-01-url"
deadmanssnitch-hivei01ue1-url = "https://deadmanssnitch-hivei01ue1-url"
deadmanssnitch-hivep01ue1-url = "https://deadmanssnitch-hivep01ue1-url"
deadmanssnitch-hivep02ue1-url = "https://deadmanssnitch-hivep02ue1-url"
deadmanssnitch-hivep03uw1-url = "https://deadmanssnitch-hivep03uw1-url"
deadmanssnitch-hivep04ew2-url = "https://deadmanssnitch-hivep04ew2-url"
deadmanssnitch-hivep05ue1-url = "https://deadmanssnitch-hivep05ue1-url"
deadmanssnitch-hivep06uw2-url = "https://deadmanssnitch-hivep06uw2-url"
deadmanssnitch-hivep07ue2-url = "https://deadmanssnitch-hivep07ue2-url"
deadmanssnitch-hives02ue1-url = "https://deadmanssnitch-hives02ue1-url"
deadmanssnitch-ocmquayrop01ew1-url = "https://deadmanssnitch-ocmquayrop01ew1-url"
deadmanssnitch-ocmquayrop01ue1-url = "https://deadmanssnitch-ocmquayrop01ue1-url"
deadmanssnitch-ocmquayrop01uw2-url = "https://deadmanssnitch-ocmquayrop01uw2-url"
deadmanssnitch-ocmquayrwp01ue1-url = "https://deadmanssnitch-ocmquayrwp01ue1-url"
deadmanssnitch-quayio-builder-url = "https://deadmanssnitch-quayio-builder-url"
deadmanssnitch-quayp04ue2-url = "https://deadmanssnitch-quayp04ue2-url"
deadmanssnitch-quayp05ue1-url = "https://deadmanssnitch-quayp05ue1-url"
deadmanssnitch-quays02ue1-url = "https://deadmanssnitch-quays02ue1-url"
deadmanssnitch-ssotest01ue1-url = "https://deadmanssnitch-ssotest01ue1-url"
deadmanssnitch-telemeter-prod-01-url = "https://deadmanssnitch-telemeter-prod-01-url"

[app-sre.creds.jiralert.stage.basic-auth]
username = "username"
password = "password"

[app-sre.creds.jiralert.prod.basic-auth]
username = "username"
password = "password"
```

In case an exception such as:
```
error processing jinja2 template: error fetching secret: key not found in config file certain/section: 'key'
```

is encountered, a new fake secret value should be added in the configuration. In our example it would be something like
```
[certain.section]
key = "a random string value"
```

### An elaborated example

Let's imagine we want to check which receiver is going handle a certain Hive production alert as defined in [ `/services/hive/hive-production-common.prometheusrules.yaml`](/resources/services/hive/hive-production-common.prometheusrules.yaml). For the sake of the example, we will choose the alert named `HiveControllersDown - production - {{{shard_name}}}` in that file.

The command asks for the following mandatory options:

```
CLUSTER NAMESPACE RULES_PATH
```

* `CLUSTER`: The cluster where the rules are deployed. In our example, we will pick `hivep02ue1`
* `NAMESPACE`: The namespace in the aforementioned cluster where the rules are deployed. It will usually be `openshift-customer-monitoring`, but it might be something else. Just look where in app-interface the rules path is referenced. For example:
  ```
  [app-interface]$ git grep /services/hive/hive-production-common.prometheusrules.yaml | grep namespaces
  data/services/observability/namespaces/openshift-customer-monitoring.hivep01ue1.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  data/services/observability/namespaces/openshift-customer-monitoring.hivep02ue1.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  data/services/observability/namespaces/openshift-customer-monitoring.hivep03uw1.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  data/services/observability/namespaces/openshift-customer-monitoring.hivep04ew2.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  data/services/observability/namespaces/openshift-customer-monitoring.hivep05ue1.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  data/services/observability/namespaces/openshift-customer-monitoring.hivep06uw2.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  data/services/observability/namespaces/openshift-customer-monitoring.hivep07ue2.yml:  path: /services/hive/hive-production-common.prometheusrules.yaml
  ```
* `RULES_PATH`: The path to the rules file in app-interface, without the leading `resources` string. In this example, `/services/hive/hive-production-common.prometheusrules.yaml`

To drill down to a specific alert, we will also use the `--alert-name` option. Its argument is the alert name once the template has been rendered. (Don't forget quotes if the alert name has embedded spaces or other shell special characters!) In our case, we will need to see how `shard_name` is resolved by checking the [namespace file](data/services/observability/namespaces/openshift-customer-monitoring.hivep02ue1.yml) used to deploy the resource. After checking it, in our case we have `hivep02ue1`.

With this information, we can run our command:

```
$ qontract-cli --config config.local.toml alert-to-receiver \
  hivep02ue1 \
  openshift-customer-monitoring \
  /services/hive/hive-production-common.prometheusrules.yaml \
  --alert-name "HiveControllersDown - production - hivep02ue1" \
  --secret-reader config
HiveControllersDown - production - hivep02ue1|pagerduty-app-sre,slack-hive-alerts
```

## A note on additional labels

There are two labels that are added to all alerts that are triggered:

* `environment`
* `cluster`

If your routing tree takes those into account, take a look into [`saas-observability-per-cluster.yaml`](/data/services/observability/cicd/saas/saas-observability-per-cluster.yaml) to find the value for your alert (hint: it will usually be either `staging` or `production`, but there are others for special cases).

With this information, the above example could be written as:

```
$ qontract-cli --config config.local.toml alert-to-receiver \
  hivep02ue1 \
  openshift-customer-monitoring \
  /services/hive/hive-production-common.prometheusrules.yaml \
  --alert-name "HiveControllersDown - production - hivep02ue1" \
  --additional-label cluster=hivep02ue1 \
  --additional-label environment=production \
  --secret-reader config
HiveControllersDown - production - hivep02ue1|pagerduty-app-sre,slack-hive-alerts
```

## Additional labels for testing purposes

Additional labels take precedence over the labels defined in the alert. This can be used to test how an alert's routing would be modified if a certain label value changed without needing to edit the rules file in app-interface and restart the local server, etc... For example, the routing of the following alert:

```
$ qontract-cli --config config.local.toml alert-to-receiver \
  clairp01ue1 \
  openshift-customer-monitoring \
  /observability/prometheusrules/clair-rate-limiting-index-report-creation-production.prometheusrules.yaml \
  -a ClairIndexReportCreationRateLimiting \
  -s config
ClairIndexReportCreationRateLimiting|pagerduty-app-sre-fts-only,slack-app-sre-alerts,slack-oncall-quay
```

will change if we change the severity. Let's try via the additional labels:

```
$ qontract-cli --config config.local.toml alert-to-receiver \
  clairp01ue1 \
  openshift-customer-monitoring \
  /observability/prometheusrules/clair-rate-limiting-index-report-creation-production.prometheusrules.yaml \
  -a ClairIndexReportCreationRateLimiting \
  -s config \
  -l severity=medium
ClairIndexReportCreationRateLimiting|slack-oncall-quay
```

## Testing changes locally

If you are preparing a MR to modify routing of one or more alerts, this tool facilitates local testing of the changes.

To begin, make sure you are [running qontract-server locally](#qontract-server).

The local server loads the graph based on the state of the repository when the server is started. Thus, you must *restart* the server to make it reflect any local edits to routing tree or rules files. However, as described [above](#additional-labels-for-testing-purposes), you may be able to iterate more quickly on rule changes by using the `--additional-label` option.

<!-- TODO: examples of local testing for a) routing tree, b) alert -->
