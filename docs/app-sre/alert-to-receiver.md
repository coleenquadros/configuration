# Alert to receiver discovery

Alertmanager routing tree in app-interface is a large beast and it is sometimes quite hard to really understand where a certain alert will finally go. The `amtool config routes test` command can be used to test the routing tree against certain alert labels. In order to make it easy to work with app-interface's Alertmanager configuration and the fact that many of the prometheus rules are actually jinja templates, we have created a `qontract-cli` command to conveniently wraps `amtool`:

```
$ qontract-cli --config config.local.toml alert-to-receiver --help
Usage: qontract-cli alert-to-receiver [OPTIONS] CLUSTER NAMESPACE RULES_PATH
                                      ALERT_NAME

Options:
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

In order to use this tool, the easiest option is to clone the `qontract-reconcile` repository. You will need Python 3.9

```
$ git clone https://github.com/app-sre/qontract-reconcile
$ cd qontract-reconcile
$ python -m venv venv && source venv/bin/activate && pip install -e .
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

This is also interesting in terms of testing changes locally before sending a MR.

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
deadmanssnitch-centralci-url = "https://deadmanssnitch-centralci-url"
deadmanssnitch-quay-builder-url = "https://deadmanssnitch-quay-builder-url"
deadmanssnitch-ci-ext-url = "https://deadmanssnitch-ci-ext-url"
deadmanssnitch-app-sre-prod-01-url = "https://deadmanssnitch-app-sre-prod-01-url"
deadmanssnitch-app-sre-prod-03-url = "https://deadmanssnitch-app-sre-prod-03-url"
deadmanssnitch-app-sre-prod-04-url = "https://deadmanssnitch-app-sre-prod-04-url"
deadmanssnitch-app-sre-stage-01-url = "https://deadmanssnitch-app-sre-stage-01-url"
deadmanssnitch-app-sre-stage-02-url = "https://deadmanssnitch-app-sre-stage-02-url"
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
deadmanssnitch-hshifti01ue1-url = "https://deadmanssnitch-hshifti01ue1-url"
deadmanssnitch-hsservicei01ue1-url = "https://deadmanssnitch-hsservicei01ue1-url"
deadmanssnitch-kcps01ue1-url = "https://deadmanssnitch-kcps01ue1-url"
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

a new fake secret value should be added in the configuration. In our example it would be something like
```
[certain.section]
key = "a random string value"
```

### An elaborated example

Let's imagine we want to check which receiver is going handle a certain Hive production alert as defined in the [ `/services/hive/hive-production-common.prometheusrules.yaml`](/resources/services/hive/hive-production-common.prometheusrules.yaml). For the sake of the example, we will chose the alert named `HiveControllersDown - production - {{{shard_name}}}` in that file.

The command asks for the following mandatory options:

```
CLUSTER NAMESPACE RULES_PATH ALERT_NAME
```

* `CLUSTER`: The cluster where the rules are deployed. In our example, we will pick `hivep02ue1`
* `NAMESPACE`: The namespace in the aforementioned cluster where the rules are deployed. It will usually be `openshift-customer-monitoring`, but it can be other. Just look where in app-interface is the rules path referenced.
* `RULES_PATH`: The rules path in app-interface (without the leading `resources` string)
* `ALERT_NAME`: The alert name once the template has been rendered. In our case, we will need to see how `shard_nbame` is resolved by checking the [namespace file](data/services/observability/namespaces/openshift-customer-monitoring.hivep02ue1.yml) used to deploy the resource. After checking it, in our case we have `hivep02ue1`

With this information, we can run our command:

```
$ qontract-cli --config config.local.toml alert-to-receiver \
  --secret-reader config \
  hivep02ue1 \
  openshift-customer-monitoring /\
  /services/hive/hive-production-common.prometheusrules.yaml \
  "HiveControllersDown - production - hivep02ue1"
pagerduty-app-sre,slack-hive-alerts
```

### A note on additional labels

There are two labels that are added to all alerts that are triggered:

* `environment`
* `cluster`

If your routing tree take those into account, take a look into [`saas-observability-per-cluster.yaml`](/data/services/observability/cicd/saas/saas-observability-per-cluster.yaml) to find the value for your alert (hint: it will usually be either `staging` or `production`, but there are others for special cases).

With this information, the above example could be written as:

```
$ qontract-cli --config config.local.toml alert-to-receiver \
  --secret-reader config \
  --additional-label cluster=hivep02ue1 \
  --additional-label environment=production \
  hivep02ue1 \
  openshift-customer-monitoring /\
  /services/hive/hive-production-common.prometheusrules.yaml \
  "HiveControllersDown - production - hivep02ue1"
pagerduty-app-sre,slack-hive-alerts
```
