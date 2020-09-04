<!-- vscode-markdown-toc -->
* [White box monitoring](#Whiteboxmonitoring)
* [Black box monitoring](#Blackboxmonitoring)
* [Prometheus](#Prometheus)
	* [Access](#Access)
	* [Monitoring using Prometheus](#MonitoringusingPrometheus)
		* [Deployment structure](#Deploymentstructure)
		* [RDU](#RDU)
		* [BLR](#BLR)
		* [Cluster prometheus](#Clusterprometheus)
		* [App-SRE prometheus](#App-SREprometheus)
		* [Adding an application to monitoring](#Addinganapplicationtomonitoring)
	* [Alerting with Alertmanager](#AlertingwithAlertmanager)
		* [Configuring alertmanager](#Configuringalertmanager)
		* [Supported notification channels](#Supportednotificationchannels)
		* [Notification templates](#Notificationtemplates)
		* [Alerting for your applications](#Alertingforyourapplications)
		* [Recommended Alerts](#RecommendedAlerts)
		* [Availability](#Availability)
		* [SLO Based](#SLOBased)
	* [Visualization with Grafana](#VisualizationwithGrafana)
		* [Configuring grafana](#Configuringgrafana)
		* [Adding datasources](#Addingdatasources)
		* [Adding dashboards](#Addingdashboards)
		* [Updating dashboards](#Updatingdashboards)
	* [Defining application performance Parameters](#DefiningapplicationperformanceParameters)
		* [Prequisites:](#Prequisites:)
		* [Process:](#Process:)
		* [App-Interface Performance Parameters Schema:](#App-InterfacePerformanceParametersSchema:)
* [Monitor a persistent volume's filesystem used/available space](#Monitorapersistentvolumesfilesystemusedavailablespace)
	* [Meta: Comparing the capabilities of the two stacks](#Meta:Comparingthecapabilitiesofthetwostacks)
	* [Which one is right for you](#Whichoneisrightforyou)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->
# Meta: Why do we monitor

`In control theory, observability is a measure of how well internal states of a system can be inferred from knowledge of its external outputs.`

**TLDR:** Because we need to know when a customer cannot use our software.

**The long answer:**

As a stakeholder of the product, we want to ensure that the services we run are available, performant and meet the specified SLA's.

To ensure this, we need to measure the current performance of the application, and get to know when it doesn't match the agreed expectations.

Instead of making humans manually observe the performance of the application, we make use of tooling that lets us gather these interesting metrics, alert us on pre-set conditions, and visualize the metrics for an overview of how the different services are behaving.

The industry is mostly in agreement, that the three facets of observability are:

- Metrics
- Logging
- Tracing

In this document, we discuss mostly the first topic, which is metrics, and to accompany that, also look at how we can provide meaningful alerting and visualization based on those metrics.

# What do we monitor

`Metrics: a system or standard of measurement.`

An overview of monitoring is incomplete without specifying 'what' we want to monitor. There can be multiple approaches to this, and one good way to think about it is:

'Measure the state of the systems, so that you will know before the customer knows that something is wrong'

In the end, we want to provide reliable services to the customers, and the customer doesn't even know whether the service is using a database or something else. What's important for us as Service owners is to make sure that we have an understanding of how the Application and its dependencies fit together, so that its easier for us to identify failure modes for the service well in advance before it becomes customer-impacting.

With that in mind, lets look at the types of monitoring we can have:

## <a name='Whiteboxmonitoring'></a>White box monitoring

- Application metrics
- Node metrics
- Metrics from external dependencies (AWS)
- Jenkins jobs
- Cluster health

## <a name='Blackboxmonitoring'></a>Black box monitoring

- Application external endpoints
    - Availability
    - Response latency
    - SSL certs
    - Response codes

- External dependencies not owned by team (Github, DNS, upstream SSO)
- Nodes
- Jenkins jobs
- Cluster endpoints

# How do we monitor

## <a name='Prometheus'></a>Prometheus

### <a name='Access'></a>Access

Access to Prometheus, Grafana and Alertmanager running on app-sre clusters is managed via the app-interface

You can self service this access by sending a pull request to the app-interface datafile corresponding to your 'role', and once the PR is accepted, the integrations will grant access for your user. The permissions are defined with the `app-sre-observability` role.

An example PR for granting access is: https://gitlab.cee.redhat.com/service/app-interface/merge_requests/130

Access to Grafana is also available for anyone is the OpenShift GitHub organization by using the following URL:

https://grafana.openshift-app-sre.devshift.net

### <a name='MonitoringusingPrometheus'></a>Monitoring using Prometheus

#### <a name='Deploymentstructure'></a>Deployment structure

>A high level architecture/overview of the stack is available in the slides here: https://docs.google.com/presentation/d/1cTW5rWy2xCnAsOlND21tZFbxwVUVv5ya0P-4Wb_9k40/edit#slide=id.gc6f73a04f_0_0

Prometheus by design tries to be simple, and it is intended that we run one Prometheus per environment for separation of concern and isolation of failure domains.

It is thus important to clarify the various Prometheus instances we have:

#### <a name='RDU'></a>RDU

The RDU cluster has a Prometheus instance on one of the nodes. It can be accessed through http://prometheus.devshift.net:9090

The configuration of this instance is done via ansible. The configuration lives in the infra repo at: [link](https://gitlab.cee.redhat.com/app-sre/infra)

The nodes being monitored all have node-exporter installed as part of the baseline playbook [link](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-all-baseline.yml)

Other than the node exporter, any applications running on top of the nodes may provide application metrics endpoints through native instrumentation or plugins, and can be added to the Prometheus.

This instance gathers the following metrics:

- Node metrics for RDU nodes, via node exporter

#### <a name='CentralCI'></a> CentralCI

The CentralCI prometheus can be found at: http://prometheus.centralci.devshift.net:9090/graph

The configuration of this instance is done via ansible. The configuration lives in the infra repo at: [link](https://gitlab.cee.redhat.com/app-sre/infra)

The nodes being monitored all have node-exporter installed as part of the baseline playbook [link](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-all-baseline.yml)

Other than the node exporter, any applications running on top of the nodes may provide application metrics endpoints through native instrumentation or plugins, and can be added to the Prometheus.

This instance gathers the following metrics:

- Node metrics for the underlying nodes in BLR lab, via node exporter

- Jenkins ci.int metrics via the Jenkins Prometheus Plugin

#### <a name='Clusterprometheus'></a>Cluster prometheus

Starting OpenShift 3.11, every cluster comes preinstalled with the cluster-monitoring operator. This operator starts a Prometheus instance that is preconfigured to alert on known cluster-level issues, and gathers metrics from the following sources:

- Node_exporter daemonsets on all nodes
- Kubernetes apiserver
- Kube-state-metrics

The cluster prometheus also have predefined alerting rules for cluster failures, based on OpenShift team's operational experience and known standard practices.

#### <a name='App-SREprometheus'></a>App-SRE prometheus

Please see the [openshift-customer-monitoring](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/osdv4-openshift-customer-monitoring.md) documentation for details on how the monitoring stack is deployed on OSD v4.

Overall, the Prometheus deployment on the app-sre cluster monitors the following:

- Application metrics
- External endpoints via Blackbox exporter
- Cloudwatch metrics via cloudwatch exporter

#### <a name='Addinganapplicationtomonitoring'></a>Adding an application to monitoring

**Application metrics:**

In app-interface, create a `ServiceMonitor` custom resource file in the `app-sre-prometheus` namespace on the cluster where your application is running.

For example, a `ServiceMonitor` for the app-sre cluster looks like: https://gitlab.cee.redhat.com/service/app-interface/blob/f0fe35941d538d6231ce52dbe333dc4c1622847a/resources/observability/servicemonitors/app-interface.servicemonitor.yaml

And the `ServiceMonitor` must also be referenced from the namespace.yml, like this: https://gitlab.cee.redhat.com/service/app-interface/blob/f0fe35941d538d6231ce52dbe333dc4c1622847a/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml#L212-217

Add observability access to your namespace(s) like this: https://gitlab.cee.redhat.com/service/app-interface/-/blob/88f829b1d3b164dc345e7d94ac51ed9cd3a72cad/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml#L175

Once the PR in app-interface is merged, your application should appear on the prometheus corresponding to the cluster. On the app-sre cluster, the URL you'd want to check is https://prometheus.app-sre-prod-01.devshift.net/targets

In case your application doesn't show up in the `targets` section, please follow this troubleshooting guide: https://github.com/coreos/prometheus-operator/blob/master/Documentation/troubleshooting.md

If all else fails, ping the interrupt catcher on #sd-app-sre

**Blackbox healthchecks:**

If you have a `Route` for your application that's facing the internet, we can add a blackbox healthcheck that helps gather data around latency and availability.

Please add a JIRA issue on the APPSRE board and we will create a blackbox exporter check for you.

Also remember to point to any basic auth creds or a machine token if your application needs authentication to reach.

### <a name='AlertingwithAlertmanager'></a>Alerting with Alertmanager

#### <a name='Configuringalertmanager'></a>Configuring alertmanager

Every app-sre managed cluster has an alertmanager alongside the prometheus. This is deployed via the prometheus-operator and has 3 replicas. Each of the replicas in the statefulset has a PVC where the pods store silences.

The configuration for alertmanager has credentials/sensitive information, so it is currently stored in vault and can be changed only by app-sre team members. If you'd like to request a change, please do so via creating a task on the App-SRE jira board and ping the #sd-app-sre channel.

All of the prometheus instances are expected to fire their alerts against their local alertmanager via the route: `https://alertmanager.<clustername>.devshift.net`

The prometheus additional alertmanager configuration is already set up to do this.

The configuration uses a central alertmanager so that we can provide alerts deduplication, have the routing tree configuration in a central place, and avoid having to manage the escalation procedures in multiple alertmanager instances across each of our clusters.

#### <a name='Supportednotificationchannels'></a>Supported notification channels

- Slack
- Email* : App-SRE doesn't recommend or actively support email alerts. This is a best-effort channel and will be at lowest priority
- Pagerduty

#### <a name='Notificationtemplates'></a>Notification templates

Alertmanager supports notification templates, which allows us to adjust the appearance of alert messages going to the channels. The documentation for setting up such templates is available upstream https://prometheus.io/docs/alerting/notification_examples/

The currently used notification template for Alertmanager in production can be found in [Vault](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-prometheus/alertmanager/alertmanager-app-sre)

Only the app-sre team members have access to this configuration

#### <a name='Alertingforyourapplications'></a>Alerting for your applications

Metrics are only so useful if you're not alerting on significant events or errors.

To get started with alerting, first ensure that the metrics for your application are being scraped by Prometheus. If in doubt, see [Monitoring](#monitoring-using-prometheus)

For example on the app-sre cluster, you can see if you have a `job` for your application in the `targets` tab at : https://prometheus.app-sre-prod-01.devshift.net

The next step is adding alerting rules for your application.

##### Adding alerting for an application from scratch

Alerts in the Prometheus world are represented in the same language as the queries : PromQL

Since we're using the Prometheus Operator, alerts for the components are represented in the form of a `PrometheusRule` Custom resource, which we collect here:
https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources/observability/prometheusrules

For example, a PrometheusRule CR should look something like:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    prometheus: app-sre
    role: alert-rules
  name: component-<staging|prod>
spec:
  groups:
  - name: component-<staging|prod>
    rules:
    - alert: componentDown - prod
      annotations:
        message: "A message that this alert shows in Slack/email. Supports templating: {{ $labels.namespace }}"
        # Link to the standard operating procedure for the component
        runbook: "https://gitlab.cee.redhat.com/observatorium/configuration/tree/master/docs/sop"
        # Link to the component's dashboard, pre-selecting the variables is preferred, for example:
        dashboard: "https://grafana.app-sre.devshift.net/d/Tg-mH0rizaSJDKSADJ/telemeter?orgId=1&var-datasource=app-sre-prometheus&var-cluster=app-sre&var-namespace=telemeter-production"
      expr: |
        absent(up{job="telemeter-server",namespace="telemeter-production"} == 1)
      # Time for which prometheus waits before actually sending out a notification while the rule about is true
      for: 15m
      # Any additional labels that you want to apply for grouping
      # both the `service` and `severity` labels are mandatory
      labels:
        service: telemeter
        severity: critical
```

It is important to note that the `PrometheusRule` must also be referenced from the namespace.yml: https://gitlab.cee.redhat.com/service/app-interface/blob/f0fe35941d538d6231ce52dbe333dc4c1622847a/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml#L108-148

To add alerting for your application, create a manifest in the same directory as other PrometheusRules for the cluster, and reference it in the namespace.yml if its not already present.

Next, its time to write the rules(conditions) you want to alert on

##### Alert Severities

Before we start writing the rules, note the following kinds of `Severity` you can have on the alerts.

All alerts that are newly added should start from the bottom of the chain i.e. `info` severity unless classified as an exception by SRE at the time of a PR review.

This allows us to see the behaviour of alert in practice, and build confidence around the thresholds set for the alert. This also lets us make sure that the templating for the alerts is correct, and someone receiving the alert is able to act on it.

One mandate for the alerts being promoted to a severity that involves the App-SRE team is adding a standard operating procedure for each alert. An example can be seen here: https://gitlab.cee.redhat.com/observatorium/configuration/blob/master/docs/sop/telemeter.md#sop--openshift-telemeter

- `critical` alerts go to App-SRE's Pagerduty. Note that this MUST meet the conditions stated above, and should relate to a degraded customer experience that's imminent already ongoing. Please reach out to the App-SRE team before you set an alert with this Severity.
- `high` alerts go to your team's slack channel, and also to App-SRE team's slack. These are alerts where either of the teams will take action according to the SOP, but the other team also needs to be in the loop for escalations
- `medium` alerts go only to your team's slack channel. These are alerts that the engineering team doesn't necessarily require SRE intervention on. The team may reach out to SRE out of the loop if there's any blockers in resolution

- `info` We optionally provide an `info` severity that's mostly informational for the team. App-SRE doesn't act on any alerts of this severity. We recommend isolating these notifications to a channel separate from the alerts channel to avoid notification fatigue

If you want to set the alert severity to below medium, you should consider if the condition is something you want to alert a developer on, because interrupt fatigue is a common situation and we'd like to avoid that.

All alert rules must include the `service` and `severity` labels on them, so that we can redirect them to the correct team

#### <a name='RecommendedAlerts'></a>Recommended Alerts

#### <a name='Availability'></a>Availability

It is mandatory to define an alert for availabilty of at least one Ready pod for your Service in the Kubernetes.
The alert rule is relatively simple, an example is:

```yaml
absent(up{job="telemeter-server",namespace="telemeter-production"} == 1)
```

This rule will fire an alert if there's no pod serving your application in the specified namespace.

The App-SRE team also adds default alerts for known Kubernetes failure domains like pods being in CrashloopBackOff and Kubernetes Platform level issues.

#### <a name='SLOBased'></a>SLO Based

Each service has some predefined Service level objectives. In case yours doesn't, it still helps to think of alerting in terms of errors that a customer is seeing.

**Error rates:**

This is defined as the percent of requests from a client that receive an 'error' response, including but not limited to 4xx and 5xx responses.
The standard prometheus library for most languages provides an `http_requests_total` metric that's partitioned on the response code, which can be used for this alert.

For example:

```yaml
sum without(instance, pod, job, code) (rate(http_requests_total{code=~"^(?:5..)$",handler="upload",job="telemeter-server",namespace="telemeter-production",service="telemeter-server"}[5m]))
/
sum without(instance, pod, job, code) (rate(http_requests_total{handler="upload",job="telemeter-server",namespace="telemeter-production",service="telemeter-server"}[5m])) * 100 > 10
```

Alerts when there's more than 10 5xx response on average for a 5 minute window

**Latency:**

It is also recommended to keep a watch on the latency of responses from your services to clients.

One common metric for this is `http_request_duration_seconds`

You generally want to alert on Percentiles for this metric, for example:

```yaml
histogram_quantile(0.99, sum(rate(prometheus_http_request_duration_seconds_bucket{namespace="telemeter-production",pod="prometheus-telemeter-0",service="prometheus-telemeter"}[5m])) by (le)) > 10
```

The above rule fires if the 99th Percentile response time for the service is greater than 10 seconds. The rule should match closely with what your Service Level Objectives are. Its okay to have a baseline expectation in the beginning and then fine tune it based on the data obtained.

**Service Specific alerts:**

Only a subset of possible alerts can be generalized for all services. As the developer, you are in the best position to know the failure domains of the service. Such cases should be converted in the alerts so that we can provide our customers with a resilient service.

In case you need consultation on service specific alerts, the App-SRE team, please request a sync via the #sd-app-sre channel on slack, or via a JIRA issue on the App-SRE board.

### <a name='VisualizationwithGrafana'></a>Visualization with Grafana

#### <a name='Configuringgrafana'></a>Configuring grafana

The App-SRE team runs a central grafana instance at in the app-sre cluster. Once you have access, you can get to the grafana instance at https://grafana.app-sre.devshift.net

The Grafana instance is configured without admin privileges for any user. To encourage repeatable configuration, we store all the configuration in Git and go through the standard CI/CD process like any other application.

#### <a name='Addingdatasources'></a>Adding datasources

Since the App-SRE grafana does not allow admin users and we want to maintain all the config as code, the Grafana provisioning mechanism is used to add the desired datasources into grafana.

The datasource files have sensitive credentials, so they're currently managed via vault. You can find them here: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/datasources

To add another datasource, edit the `datasources.yaml` file, adding a new JSON object into the list. Next, regenerate the configmap using a command like:

`oc create secret generic grafana-datasources --from-file=datasources.yaml -o yaml --dry-run > grafana-datasources.secret.yaml`

Next, apply the secret and redeploy grafana.

Currently added datasources:

* `app-sre-stage-01-prometheus`: app-sre managed prometheus for `app-sre-stage-01` cluster
* `app-sre-stage-01-cluster-prometheus`: cluster prometheus for `app-sre-stage-01` cluster
* `app-sre-prod-01-prometheus`: app-sre managed prometheus for `app-sre-prod-01` cluster
* `app-sre-prod-01-cluster-prometheus`: cluster prometehus for `app-sre-prod-01` cluster
* `quayiop03ue1-prometheus`: app-sre managed prometheus for `quayp03ue1` cluster
* `quayiop04ue2-prometheus`: app-sre managed prometheus for `quayp04ue2` cluster
* `quays02ue1-prometheus`: app-sre managed prometheus for `quays02ue1` cluster
* `AWS app-sre`: cloudwatch AWS appsre
* `dsaas-graphite`: graphite on `app-sre-prod-03` cluster
* `dsaas-bayesian-stage-graphite`: bayesian graphite on `app-sre-stage-02` cluster
* `dsaas-bayesian-production-graphite`: bayesian graphite on `app-sre-prod-03` cluster
* `starter-us-east-2-cluster-prometheus`: cluster prometheus on `starter-us-east-2-cluster` cluster
* `starter-us-east-2a-cluster-prometheus`: cluster prometheus on `starter-us-east-2a-cluster` cluster
* `starter-us-east-1a-cluster-prometheus`: cluster prometheus on `starter-us-east-1a-cluster` cluster
* `starter-us-east-1b-cluster-prometheus`: cluster prometheus on `starter-us-east-1b-cluster` cluster
* `elasticsearch-monitoring`: `.monitoring-es*` database on AWS elasitcsearch
* `elasticsearch-logstash`: `.monitoring-logstash*` database on AWS elasitcsearch

For those clusters that have a `-prometheus` and `-cluster-prometheus` datasources, app-sre managed services will keep its data on the `-prometheus` ones as the other is managed by OSD and used for cluster internal metrics.

In case of doubt, the [grafana datasources file](/resources/observability/grafana/grafana-datasources.secret.yaml) is the source of truth and the place to get all the details on every datasource.

#### <a name='Addingdashboards'></a>Adding dashboards

Setting the correct datasource:

Make sure you have a variable named `datasource` on each of your dashboards.
All panels MUST query to this variable ($datasource). You can set this by editing the panel

For example: Creating a variable called `datasource` has the following steps.

In Dashboard Settings -> Variables -> New:
* Name: datasource
* Type: Datasource
* Datasource Options.type: `Prometheus`
* Datasource Options.instanceNameFilter: `/a regexp limiting the datasources available for your dashboard/`

> NOTE: It is **very** important that you filter the datasources relevant to your dashboard as the users of it won't usually know which are the prometheis that will have your dashboard data. Showing all the prometheus datasources available is usually wrong and will only make for a poor user experience.

Click Add.

Next up, change all your panels to send queries to this datasource

Since the Grafana instance is read-only, there is no 'save' button for the dashboard changes you make. In order to add a new dashboard, you should use the 'Grafana Playground' dashboard. The Grafana Playground dashboard has one instance each for each of the supported panels. You can duplicate the panels as many times as you'd like, and use the query view to add the graphs for desired metrics. Once that's done, export the dashboard as json, and send a pull requests to our dashboards configuration here: [link](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources/observability/grafana)

Dashboards are injected into grafana as configmaps, to generate a configmap from an existing dashboard, use a command similar to:

`oc create configmap grafana-dashboard-<name_of_dashboard> --from-file=<dashboard_file.json> -o yaml --dry-run > grafana-dashboard-<name_of_dashboard>.configmap.yaml`

Once the pull request is merged, the app-interface will automatically apply the configmap. No restart of the Grafana server deployment is needed.

In case you have any questions about adding a new dashboard, the App-SRE team can offer a best-effort support on walking you through the steps, but we hope that the documentation here is enough :)

#### <a name='Updatingdashboards'></a>Updating dashboards

Updating a dashboard has a very similar workflow to adding one, except that the namespace reference is already present.

To update a dashboard:

- Edit the dashboard on https://grafana.app-sre.devshift.net
- On the top right side of the page, click the `Share` icon
- Navigate to the `Export` tab
- Check `Export for sharing externally` ; This is highly important
- Save to file
- Generate a configmap with the command:
`oc create configmap grafana-dashboard-<name_of_dashboard> --from-file=<dashboard_file.json> -o yaml --dry-run > grafana-dashboard-<name_of_dashboard>.configmap.yaml` and send a pull request to app-interface to update the file in `resources`

As an example, a pull request for updating an existing dashboard is: https://gitlab.cee.redhat.com/service/app-interface/merge_requests/637

---

### <a name='DefiningapplicationperformanceParameters'></a>Defining application performance Parameters

References: 
- https://landing.google.com/sre/sre-book/chapters/service-level-objectives/
- https://landing.google.com/sre/workbook/chapters/implementing-slos/
- Service Delivery Vernacular: https://docs.google.com/document/d/1yaKNMN1R-sX5VZhd8cEdR3ZJNjWWp6BLUTTutQrEsDM/edit#

#### <a name='Prequisites:'></a>Prequisites:
- App-SRE supported monitoring model with Prometheus
- Application onboarded to App-SRE onboarding model
- Application has metrics instrumentation and already being monitored by one of App-SRE's Prometheus instances

#### <a name='Process:'></a>Process:

- Service owners and product managers (along with SRE consultation) agree upon SLI's and SLO's. For quicker iterations, this can be a Google doc.
- A template to get help new applications document their SLO's is provided here: 
- Once the SLI's and SLO's have been defined and reviewed by stakeholders, send a pull request to the app-interface. 

#### <a name='App-InterfacePerformanceParametersSchema:'></a>App-Interface Performance Parameters Schema: 

The App-SRE team has created a schema that allows service owners to define their application's SLX in app-interface.  See this [doc](/docs/app-sre/sli-recording-rules-via-performance-parameters.md) for further information.

# Getting started

# How-To

## <a name='Monitorapersistentvolumesfilesystemusedavailablespace'></a>Monitor a persistent volume's filesystem used/available space

If your application can expose a metric that tells how much free/available disk space it sees, we'll consume it. Often cases this is not possible or desirable and in this case we use the prometheus node-exporter to expose filesystem metrics. This service should be run as a separate container (often called sidecar container) within the same pod in which you are using the volume.

A typical container spec may look like this

```yaml
- name: filesystem-metrics
  image: prom/node-exporter:v0.17.0
  args:
  - --collector.filesystem
  - --collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)
  - --collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$
  - --no-collector.arp
  - --no-collector.bcache
  - --no-collector.bonding
  - --no-collector.buddyinfo
  - --no-collector.conntrack
  - --no-collector.cpu
  - --no-collector.diskstats
  - --no-collector.drbd
  - --no-collector.edac
  - --no-collector.entropy
  - --no-collector.filefd
  - --no-collector.hwmon
  - --no-collector.infiniband
  - --no-collector.interrupts
  - --no-collector.ipvs
  - --no-collector.ksmd
  - --no-collector.loadavg
  - --no-collector.logind
  - --no-collector.mdadm
  - --no-collector.meminfo
  - --no-collector.meminfo_numa
  - --no-collector.mountstats
  - --no-collector.netdev
  - --no-collector.netstat
  - --no-collector.nfs
  - --no-collector.nfsd
  - --no-collector.ntp
  - --no-collector.qdisc
  - --no-collector.runit
  - --no-collector.sockstat
  - --no-collector.stat
  - --no-collector.supervisord
  - --no-collector.systemd
  - --no-collector.tcpstat
  - --no-collector.textfile
  - --no-collector.time
  - --no-collector.uname
  - --no-collector.vmstat
  - --no-collector.wifi
  - --no-collector.xfs
  - --no-collector.zfs
  - --no-collector.timex
  ports:
    - containerPort: 9100
      name: filesystem-metrics
  resources: {}
  volumeMounts:
    - mountPath: /the/mount/point
      name: the-volume-name
```

A corresponding service may also look like this

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: myservice-filesystem-metrics
spec:
  ports:
  - name: filesystem-metrics
    port: 9100
    protocol: TCP
    targetPort: filesystem-metrics
  selector:
    app: myapp
    foo: bar
  type: ClusterIP
```

Once this is in place, a ServiceMonitor can pick-up the endpoint and start scraping metrics.

# FAQ

### <a name='Meta:Comparingthecapabilitiesofthetwostacks'></a>Meta: Comparing the capabilities of the two stacks

> We actively track the capabilities of the two stacks here:
>
>https://docs.google.com/spreadsheets/d/1lWXWwl27VO8FIQz5eySk2CwGp47J7Psw8cwomFv9Pe0/edit#gid=0

