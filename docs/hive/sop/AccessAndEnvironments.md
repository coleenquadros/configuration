# SOP : Access and Environments

<!-- TOC depthTo:2 -->

- [SOP : Access and Environments](#sop--access-and-environments)
- [Access](#access)
- [Environments](#environments)
  - [Integration](#integration)
  - [Stage](#stage)
  - [Production](#production)
- [Metrics](#metrics)
  - [Updating the Grafana Dashboard](#updating-the-grafana-dashboard)

<!-- /TOC -->

# Access

For Hive team members who need access to stage and production environments.

Ensure you have Tier 1 access set up so you can ssh to the bastion hosts:
[https://mojo.redhat.com/docs/DOC-1144200](https://mojo.redhat.com/docs/DOC-1144200)

Hive delivers a [hive-admin role](https://github.com/openshift/hive/blob/master/config/rbac/hive_admin_role.yaml) which is bound to a `hive-admins` group maintained by SRE/AppSRE. We can self-service this and other in-cluster permissions here: [https://visual-app-interface.devshift.net/roles#/teams/hive/roles/dev.yml](https://visual-app-interface.devshift.net/roles#/teams/hive/roles/dev.yml).

If you are a member of this group, you should be able to view/list Hive CRDs if used with `-n` or `--all-namespaces`. You can view jobs, pods, and logs in all namespaces.

Accessing logging or prometheus services via github auth in stage and production environments requires being a member of the [app-sre](https://github.com/app-sre) group on github. This access can be requested in the `#sd-app-sre` channel on slack.

# Environments

We assume the use of “[sshuttle](https://github.com/sshuttle/sshuttle)” for reaching the clusters which are not on the public internet. On Fedora, install with `dnf install sshuttle`.

On macOS sshuttle does not work by default if you are on the VPN.

As per [this bug](https://github.com/sshuttle/sshuttle/issues/102/) to the sshuttle project you will need to manually add a route.

An example on how to do so:

`sudo route add -net <range_to_go_through_sshuttle> -interface lo0`

## Integration

To access monitoring services for the integration environment, there's no need to run `sshuttle` as the integration environment is open to the world.

Login to the API via `oc` by obtaining a token from [https://api.hive-integration.openshift.com/oauth/token/request](https://api.hive-integration.openshift.com/oauth/token/request)

```
oc login --token=TOKEN --server=https://api.hive-integration.openshift.com
```

| Service    | URL |
| ---------- | --- |
| Console    | [https://console.hive-integration.openshift.com/console/project/hive/overview](https://console.hive-integration.openshift.com/console/project/hive/overview) |
| Logs       | [https://logs.hive-integration.openshift.com/](https://logs.hive-integration.openshift.com/) |
| Prometheus | [https://prometheus-k8s-openshift-monitoring.c39b.hive-integration.openshiftapps.com/](https://prometheus-k8s-openshift-monitoring.c39b.hive-integration.openshiftapps.com/) |

## Stage

To access monitoring services for the stage environment, open a `sshuttle` connection to stage:

```
sshuttle -r bastion-useast2-1 10.140.0.0/16
```

Note: `bastion-useast2-1` is an alias added to sshconfig. See the [Tier 1 access](https://mojo.redhat.com/docs/DOC-1144200) doc. Authenticating via ssh to the bastion host uses Red Hat two factor auth from [https://token.redhat.com/](https://token.redhat.com/).

Login to the API via `oc` by obtaining a token from [https://api.hive-stage.openshift.com/oauth/token/request](https://api.hive-stage.openshift.com/oauth/token/request)

```
oc login --token=TOKEN --server=https://api.hive-stage.openshift.com
```

| Service    | URL |
| ---------- | --- |
| Console    | [https://console.hive-stage.openshift.com/console/project/hive/overview](https://console.hive-stage.openshift.com/console/project/hive/overview) |
| Logs       | [https://logs.hive-stage.openshift.com/](https://logs.hive-stage.openshift.com/) |
| Prometheus | [https://prometheus-k8s-openshift-monitoring.c39b.hive-stage.openshiftapps.com/](https://prometheus-k8s-openshift-monitoring.c39b.hive-stage.openshiftapps.com/) |

## Production

To access monitoring services for the production environment, open a `sshuttle` connection to stage:

```
sshuttle -r bastion-useast2-1 10.121.0.0/16
```

Note: `bastion-useast2-1` is an alias added to sshconfig. See the [Tier 1 access](https://mojo.redhat.com/docs/DOC-1144200) doc. Authenticating via ssh to the bastion host uses Red Hat two factor auth from [https://token.redhat.com/](https://token.redhat.com/).

Login to the API via `oc` by obtaining a token from [https://api.hive-production.openshift.com/oauth/token/request](https://api.hive-production.openshift.com/oauth/token/request)

```
oc login --token=TOKEN --server=https://api.hive-production.openshift.com
```

| Service    | URL |
| ---------- | --- |
| Console    | [https://console.hive-production.openshift.com/console/project/hive/overview](https://console.hive-production.openshift.com/console/project/hive/overview) |
| Logs       | [https://logs.hive-production.openshift.com/](https://logs.hive-production.openshift.com/) |

# Metrics

Metrics for all Hive environments are available at: [https://prometheus.app-sre.devshift.net/](https://prometheus.app-sre.devshift.net/)

A dashboard is available at: [https://grafana.app-sre.devshift.net/d/hive/hive?orgId=1](https://grafana.app-sre.devshift.net/d/hive/hive?orgId=1)

Note that accessing metrics does not require using `sshuttle`.

## Updating the Grafana Dashboard

The grafana dashboard is read-only, you can edit it as you wish, but on refresh your changes will be lost. 

To persist dashboard changes: 

1. Hit the Share Dashboard button at the top of the page.
2. Nav to Export tab, and check the “external” switch, then save to file.
3. Clone or fork: [https://gitlab.cee.redhat.com/service/app-interface](https://gitlab.cee.redhat.com/service/app-interface)
4. Create a branch.
5. Update the dashboard configmap with your exported changes. 
   1. Config map location: resources/app-sre/app-sre-observability-production/grafana/grafana-dashboard-hive.configmap.yaml

   ```
   oc create configmap grafana-dashboard-hive --from-file=hive.json -o yaml --dry-run > resources/app-sre/app-sre-observability-production/grafana/grafana-dashboard-hive.configmap.yaml
   ```
6. Submit a PR with the resulting change.
