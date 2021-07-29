# console.redhat.com Developer Onboarding

- [console.redhat.com Developer Onboarding](#cloudredhatcom-developer-onboarding)
  - [Quick Links](#quick-links)
  - [Asking for Help](#asking-for-help)
  - [Forking the app-interface GitLab Repo](#forking-the-app-interface-gitlab-repo)
  - [Accessing Stage Environment](#accessing-stage-environment)
  - [Logging into quay.io](#logging-into-quayio)
  - [Using insights-client in Stage](#using-insights-client-in-stage)
  - [Accessing Production Environment](#accessing-production-environment)
  - [Connect with App SRE on Slack](#connect-with-app-sre-on-slack)
    - [`#sd-app-sre`](#sd-app-sre)
    - [`#team-clouddot-info`](#team-clouddot-info)
    - [`#team-clouddot-alert-stage`](#team-clouddot-alert-stage)
    - [`#sd-app-sre-reconcile`](#sd-app-sre-reconcile)
    - [CoreOS Slack](#coreos-slack)
    - [Shared Channels](#shared-channels)
  - [How to Promote an Image to Stage](#how-to-promote-an-image-to-stage)
  - [How to Promote an Image to Production](#how-to-promote-an-image-to-production)
  - [How to Update the UI in Stage](#how-to-update-the-ui-in-stage)
  - [How to Update Secrets in Vault](#how-to-update-secrets-in-vault)
    - [Getting access to Vault](#getting-access-to-vault)
    - [Logging into Vault](#logging-into-vault)
    - [Updating Vault Secrets](#updating-vault-secrets)
  - [Metrics and Monitoring](#metrics-and-monitoring)
    - [How to migrate Grafana dashboards from saas-templates](#how-to-migrate-grafana-dashboards-from-saas-templates)
    - [How to add a Grafana dashboard](#how-to-add-a-grafana-dashboard)
    - [Adding Alerts](#adding-alerts)
    - [Route Alerts to Team Channels in CoreOS Slack](#route-alerts-to-team-channels-in-coreos-slack)
    - [RDS Enhanced Monitoring Metrics](#rds-enhanced-monitoring-metrics)

## Quick Links

* [Paging AppSRE OnCall](https://mojo.redhat.com/groups/service-delivery/blog/2020/03/19/paging-appsre-oncall)
* [app-interface deep dive slides](https://docs.google.com/presentation/d/1R1JtB29TVnANfCoy_JOxVE5ehe_6cfiVdzRrQ468TIo/edit#slide=id.g782698ae7e_2_697)
* [app-interface deep dive recording](https://bluejeans.com/s/eLhjG)
* [Production promotion epic](https://projects.engineering.redhat.com/browse/RHCLOUD-5439): You can find your respective apps in that epic and follow along with the progress.
* [Visual App-Interface](https://visual-app-interface.devshift.net/)
* [Grafana](https://grafana.app-sre.devshift.net/dashboards): App SRE uses one Granfana for all clusters; each graph chooses the datasource by cluster.

## Asking for Help

If you need assistance from an SRE, need advice, or temporary elevated access to a system, reach out to AppSRE.  During business hours, the easiest way to contact AppSRE is via the Interupt Catcher (IC).  To contact the IC, ping **@app-sre-ic** in **#sd-app-sre** in **CoreOS Slack**.

Additional contact information for AppSRE can be found [here](https://mojo.redhat.com/docs/DOC-1211223#jive_content_id_Contacting_AppSRE).

If you need emergency help after-hours, AppSRE can be paged.  Please review the information [here](https://mojo.redhat.com/groups/service-delivery/blog/2020/03/19/paging-appsre-oncall) for guidance on when to use the AppSRE pager.

## Forking the app-interface GitLab Repo

You'll need to fork the app-interface gitlab repo in order to create merge requests (MRs), which are the same thing as github PRs. If you are new to gitlab, it works almost exactly the same as github for day-to-day tasks. However some of the buttons are in different places. To fork, you'll need to:

  * go to [the app-interface repo](https://gitlab.cee.redhat.com/service/app-interface)
  * click "fork" in the upper right
  * let it fork. When complete, it will redirect you to your fork.
  * click "members" in the left-hand side bar
  * add "devtools-bot" so the bot can check your merge requests. Enter "devtools-bot" in the "GitLab member or Email address" box and grant it the "maintainer" role.
  * Click your account in the upper right, and click "settings". Click "SSH Keys" in the left side bar. Add your SSH public key (typically the contents of `~/.ssh/id_rsa.pub`).
  * after that, you should be all set! Just treat `https://gitlab.cee.redhat.com/service/app-interface` as the upstream project, and your fork as your fork, just like you would in github. When you push a new branch to your fork, you'll be provided with a link to create an MR.

More info can be found in the [workflow doc](https://gitlab.cee.redhat.com/service/app-interface#workflow).
## Accessing Stage Environment

* visual app interface (common across envs): https://visual-app-interface.devshift.net/
* UI: https://cloud.stage.redhat.com
* Openshift console: go to [Clusters](https://visual-app-interface.devshift.net/clusters) > Search "crc" > Choose cluster that says "Stage cluster" (click first link with URL in it for console, not 'details' link!)
* Prometheus: [Clusters](https://visual-app-interface.devshift.net/clusters) > Search "crc" > Choose cluster that says "stage cluster" > Details > Prometheus
* Kibana: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com
* payload tracker: https://payload-tracker-frontend-payload-tracker-stage.apps.crcs02ue1.urby.p1.openshiftapps.com/

Our stage environment follows IT's [pre-prod lockdown](https://mojo.redhat.com/docs/DOC-1193747) requirement.  Thus you must [configure your brower and scripts to use the Red Hat internal squid proxy](https://redhat.service-now.com/help?id=kb_article_view&sysparm_article=KB0006375&sys_kb_id=26c75be61b538490384411761a4bcbf9) ([alternative Mojo link](https://mojo.redhat.com/docs/DOC-1213497)) in order to access cloud.stage.redhat.com.

Your credentials are usually the same as QA:  all passwords are set to `redhat`.

**Commmand-line Examples**

You can make command-line requests to Stage using curl’s proxy flag:

```
curl --proxy http://squid.corp.redhat.com:3128 https://cloud.stage.redhat.com/api/<path>
```

If you prefer wget, you can do the same thing like this:

```
wget -e use_proxy=yes -e http_proxy=http://squid.corp.redhat.com:3128 https://cloud.stage.redhat.com/api/<path>
```

## Logging into quay.io

All images for stage and prod are stored in quay.io. Your buildfactory config in the dev cluster probably has a `quay-copier` config in it somewhere that copies images to quay for you.

If you'd like to see what's in quay.io, you can [log in](#logging-into-quay.io) with your quay.io username/pass (not kerberos) and go to the [cloudservices org](https://quay.io/organization/cloudservices). If you don't have access, you'll need to create an MR adding your user to insights-engineers [like so](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/7511). If you'd like to learn more about quay.io, check out this [15 minute tutorial](https://quay.io/tutorial/).


## Using insights-client in Stage

**NOTE:  This requires insights-client version 3.0.173+**

Edit `/etc/insights-client/insights-client.conf`:

```
auto_config=False
authmethod=BASIC
base_url=cloud.stage.redhat.com/api
username=<your customer portal username>
password=redhat (or other stage rhsm password)
legacy_upload=False
cert_verify=True
proxy=http://squid.corp.redhat.com:3128
```

## Accessing Production Environment

* visual app interface (common across envs): https://visual-app-interface.devshift.net/
* UI: https://console.redhat.com (with special cookie)
* Openshift console: go to [Clusters](https://visual-app-interface.devshift.net/clusters) > Search "crc" > Choose cluster that says "Production cluster" (click first link with URL in it for console, not 'details' link!)
* Prometheus: [Clusters](https://visual-app-interface.devshift.net/clusters) > Search "crc" > Choose cluster that says "stage cluster" > Details > Prometheus
* Set cookie: https://console.redhat.com/yOM53v3hTsaKDZJoVAtZ7r2or79PuzWI
* Kibana: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/
* payload tracker: https://payload-tracker-frontend-payload-tracker-prod.apps.crcp01ue1.o9m8.p1.openshiftapps.com/

Accessing the new production environment is done with the same URLs as our current production environment, but all your requests must contain the `x-rh-prod-v4` cookie.  Go [here](https://console.redhat.com/yOM53v3hTsaKDZJoVAtZ7r2or79PuzWI) to set the cookie in your browser.  This will keep the cookie set until your delete your cookies for console.redhat.com.

Example curl:
```
curl -u '<user>:<password>' -b "x-rh-prod-v4=1" https://console.redhat.com/api/topological-inventory/
```

Note that the old v3 cluster is also in app-interface, but it uses the prefix `insights` instead of `crc`.

## Connect with App SRE on Slack

App SRE has several different communication channels in CoreOS Slack that app devs can participate in:

### `#sd-app-sre`

This is the primary channel used to communicate with App SRE.  For immediate needs, use the `@app-sre-ic` handle to ping the App SRE engineer currently set as the "interrupt catcher".  If a question is not immediate in nature, please do not use the handle.

### `#team-clouddot-info`

app-interface is configured to send all saas-deploy notifications to this channel.  You can check this channel to see when a promtion to stage or prod completed and whether it was successful or not.

As teams become more familiar with the promotion flow, we can add team-specific channels for notifications to go to.

### `#team-clouddot-alert-stage`

Alertmanager notifications for the Insights stage environment are sent to this channel.

### `#sd-app-sre-reconcile`

This is a verbose stream of all updates being applied by the app-interface reconciliation loop.  This channel can be helpful if you want to know exactly when a recently-merged change gets applied into its target environment.

Note that some sensitive updates are not posted, e.g. secrets.

### CoreOS Slack

To log in to CoreOS Slack, go to https://coreos.slack.com and click on `Sign in with Google`. This workspace allows you to sign in with your `@redhat.com` Google account.

### Shared Channels

The channels `#cloudservices-outage` and `#team-insights-migration` are shared between the Ansible and CoreOS Slack workspaces.  Once the migration to App SRE is completed, these channels will be phased out and devs will be expected to interact with App SRE exclusively on CoreOS Slack.

If you have a question specific to setting up your app prior to the production cutover (August 11), feel free to ask in `#team-insights-migration` and use the `@platform-tools` handle.

## How to Promote an Image to Stage

1. Find the git commit from your source repo that you want to promote and copy the first seven characters, e.g `87ff3c59c94fe28d1d500a701d8acc2167cc7703` becomes `87ff3c5`. This hash is also used as the image tag in quay.io. If you'd like to confirm that the image is there and has the content you expect, you can run something like `docker run -it quay.io/cloudservices/upload-service:87ff3c5 /bin/bash`. This will pull down a local copy of the image and drop into a bash shell that you can use to inspect the image.
2. Locate your app folder in app-interface, e.g. `data/services/insights/ingress` and open `deploy.yml` (also known as `saas.yml`).
3. For each `resourceTemplate` that uses your updated image, set the `IMAGE_TAG` parameter value to your seven character git commit hash. Please ensure you are updating all pods that you want updated (for example, if you have a REST API pod and a message listener pod that you want updated, make sure you update both `IMAGE_TAG`s). Also note that both stage and production use the same file, so be mindful that you are updating only stage.
4. Commit the change, push to your fork of app-interface, and open a merge request (MR).
5. App devs need to get an owner of your saas file to approve your changes (you cannot self-approve even if you are an owner).  The devtools bot should add a comment to your MR stating which users can approve.  The approver just needs to add a comment to the MR with the content `/lgtm`.  [Example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/5684).
6. After the change is approved, go eat a chocolate croissant for 10-15 minutes. You should then see the updated image deployed to your project in stage openshift. If you don't see it, find your (deploy job)[https://ci.int.devshift.net] by searching for your app name and clicking "saas-deploy" and then click the environment you are interested in. If all else fails, you can ask for help in the channels mentioned above.

## How to Promote an Image to Production

This is the same process as stage. Just edit the production part of your `deploy.yml` when making changes, and re-use the hash you used on stage.

## How to Update the UI in Stage

The UI for the Stage environment is kept in sync with the QA environment. Follow your usual process for updating your QA UI to update your Stage UI. This generally means pushing the associated branch (such as `qa-stable`) in the source repository for your app's UI.

## How to Update Secrets in Vault

Before you can update your Vault secrets, you need to get proper access, and then log in to Vault.

### Getting access to Vault

1. Check the vault policies located at `data/services/vault.devshift.net/config/policies/insights`. If there isn't one for your team, copy an existing policy (such as `advisor-policy.yml`) and modify it to give you access to the correct Vault namespace. Name it "{TEAM_NAME}-policy.yml`.
2. Check `data/services/vault.devshift.net/config/auth-backends/github-auth.yml`. If you don't see your vault policy file from step 1, add an entry that associates your policy file with your GitHub team, eg:

```yml
  - github_team:
      $ref: /teams/insights/github-teams/{TEAM_NAME}.yml
    policies:
      - $ref: /services/vault.devshift.net/config/policies/insights/{TEAM_NAME}-policy.yml
```

3. Check `data/teams/insights/github-teams` and ensure there's a GitHub team created for your team. If not, copy one of the existing files, such as `advisor.yml`, and modify it for your team.

4. Check /data/teams/insights/roles` and ensure there's a role created for your team. In your team file, under "permissions", you should see a reference to your GitHub team file, e.g.:

```yml
permissions:
- $ref: /teams/insights/github-teams/{TEAM_NAME}.yml
```

5. Finally, edit your user file at `data/teams/insights/users` and make sure you have the role from Step 4 assigned to you, e.g.:

```yml
roles:
- $ref: /teams/insights/roles/{TEAM_NAME}.yml
```

### Logging into Vault

To log into Vault, follow the instructions in [Vault's Readme](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/vault.md#vault-user-guide).

### Updating Vault Secrets

1. Log into Vault and make sure you're at the [root URL](https://vault.devshift.net/ui/vault/secrets).

2. Navigate to your secret within the UI:

    1. Click on `insights/secrets/` to get to where console.redhat.com secrets are stored.

    2. Click on `insights-prod/` or `insights-stage/`, depending on which environment's secrets you want to modify.

    3. Click on your app, and then click on the secret you want to update.

3. Click "Create new version +" in the top-right corner.

4. Set "Maximum Number of Versions" to 0, which removes the maximum. Make updates to your secret, and hit "Save".

5. Open an app-interface MR to update the secret's version number in your app's config.

## Metrics and Monitoring

### How to migrate Grafana dashboards from saas-templates

Grafana dashboards must move from saas-templates to each app's respective source repository. This change must be completed by 9/25. Step-by-step instructions for this can be found [in this doc](https://docs.google.com/document/d/1AvRWch-6RRfnbWPOh4onjtCmP3tkRtPs7UR-URG_m7Y/edit#).

### How to add a Grafana dashboard

1. Add (or update) the dashboard file (a ConfigMap containing the json data) in your app's source repository. The dashboards must be in their own separate directory, such as `/dashboards`. If the observability configuration has already been added, each merge to this repository will deploy the dashboards to the [Grafana stage instance](https://grafana.stage.devshift.net/).

    - Note: Each dashboard ConfigMap should have the following section under `metadata`:

    ```yaml
    labels:
      grafana_dashboard: "true"
    annotations:
      grafana-folder: /grafana-dashboard-definitions/Insights
    ```

2. If you haven't already added the required observability configuration, create an app-interface MR to add it to [saas-grafana.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-grafana.yaml) by copying one of the existing entries (such as “insights-dashboards” or “telemeter-dashboards”). Modify the following fields:
    - name: The app’s name, adding “-dashboards” to the end. For example, “advisor-dashboards”.
    - url: The URL for the application’s source repository. For example, <https://github.com/RedHatInsights/insights-advisor-api>.
    - path: The repo’s local path to the folder containing the dashboards. For example, “/dashboards”.
    - The last “ref” field (the one for the Production namespace) should be set to the commit hash for the app repo’s latest commit. As an example, here’s the value used by insights-dashboards.

3. Once you've verified the changes look good on the stage grafana, open an MR updating the SHA to the latest commit in your repository to promote the dashboard changes to the [Grafana production instance](https://grafana.app-sre.devshift.net/). For example, updating [this line](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-grafana.yaml#L70) would update the (now-deprecated) insights-dashboards folder in Production Grafana.

### Adding Alerts

Each app team needs to migrate their alerts from e2e-deploy to app-interface.  App SRE-managed Openshift clusters use the Prometheus operator, thus rules and alerts are defined as a `PrometheusRule` CR (custom resource).  You can add these resources in two ways:

- Commit the resources directly to app-interface and reference it from the `openshift-customer-monitoring` namespace from your cluster.
- Add them to a separate deployment template. Deploy this by adding a resource template to your `deploy.yml`, pointing to your deployment template and targeting the `openshift-customer-monitoring` namespace on your respective cluster.  [Here is an example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/prometheus-rules-deploy.yml), with the [corresponding git repo](https://gitlab.cee.redhat.com/insights-platform/prometheus-rules).

[App SRE documentation for alerting](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/monitoring.md#alerting-for-your-applications) explains the labels you need to set and how to direct your alerts to the appropriate channel.  We currently use `insights` as the team for all alerts, but this will likely be split up into individual teams in the near future.

Alert annotations are used to render action buttons in Slack alert messages:

- `dashboard`: Link to corresponding grafana dashboard.
- `link_url`: Link to project in Openshift console
- `message`: The message you want to display in slack or pagerduy
- `runbook`: Link to SOP in platform-docs or app-interface

### Route Alerts to Team Channels in CoreOS Slack

Follow instructions documented [here](https://gitlab.cee.redhat.com/snippets/2733) to route alerts to your team channel in CoreOS slack.

### RDS Enhanced Monitoring Metrics

RDS Exporter has been deployed by AppSRE to the AppSRE cluster. It will collect metrics and publish them to the AppSRE prometheus (which is different than the Prometheus instance running on Insights cluster.) To collect metrics published by enhanced monitoring, update following ConfigMaps:

1. [Staging](../../../resources/observability/rds-exporter/crc/rds-exporter.configmap.crc-stage.yaml)
2. [Production](../../../resources/observability/rds-exporter/crc/rds-exporter.configmap.crc-prod.yaml)

Add following configuration

```yaml
    - region: us-east-1
      instance: RDS_INSTANCE_IDENTIFIER
      disable_basic_metrics: true
      disable_enhanced_metrics: false
```

1. Set `region` to the region where your RDS instance is deployed.
1. Set `instance` to your RDS instance. Note that you must have `enhanced_monitoring` set to `true` for RDS instance.
1. Set `disable_basic_metrics` to `true` as these metrics are collected by `cloudwatch-exporter.
1. Set `disable_enhanced_metrics` to `false`.

Updates to ConfigMap will update the RDS exporter deployment.
