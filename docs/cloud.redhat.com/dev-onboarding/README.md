# cloud.redhat.com Developer Onboarding

- [Quick Links](#quick-links)
- [Asking for Help](#asking-for-help)
- [Accessing Stage Environment](#accessing-stage-environment)
- [Using insights-client in Stage](#using-insights-client-in-stage)
- [Accessing Production Environment](#accessing-production-environment)
- [Connect with App SRE on Slack](#connect-with-app-sre-on-slack)
- [How to Promote an Image to Stage](#how-to-promote-an-image-to-stage)
- [How to Update the UI in Stage](#how-to-update-the-ui-in-stage)
- [How to Update Secrets in Vault](#how-to-update-secrets-in-vault)
- [How to add a Grafana dashboard](#how-to-add-a-grafana-dashboard)

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

## Accessing Stage Environment

* UI: https://cloud.stage.redhat.com
* Openshift console: visual-app-interface > Clusters > Search "crc" > Choose cluster that says "stage cluster"
* Prometheus: visual-app-interface > Clusters > Search "crc" > Choose cluster that says "stage cluster" > Details > Prometheus
* Kibana: https://kibana.apps.crc-stg-01.o4v9.p1.openshiftapps.com

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

* UI: https://cloud.redhat.com (with special cookie)
* Openshift console: visual-app-interface > Clusters > Search "crc" > Choose cluster that says "production cluster"
* Prometheus: visual-app-interface > Clusters > Search "crc" > Choose cluster that says "stage cluster" > Details > Prometheus
* Set cookie: https://cloud.redhat.com/yOM53v3hTsaKDZJoVAtZ7r2or79PuzWI
* Kibana: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/

Accessing the new production environment is done with the same URLs as our current production environment, but all your requests must contain the `x-rh-prod-v4` cookie.  Go [here](https://cloud.redhat.com/yOM53v3hTsaKDZJoVAtZ7r2or79PuzWI) to set the cookie in your browser.  This will keep the cookie set until your delete your cookies for cloud.redhat.com.

Example curl:
```
curl -u '<user>:<password>' -b "x-rh-prod-v4=1" https://cloud.redhat.com/api/topological-inventory/
```

Note that the old v3 cluster is also in app-interface, but it uses the prefix `insights` instead of `crc`.

## Connect with App SRE on Slack

App SRE has several different communication channels in CoreOS Slack that app devs can participate in:

### `#sd-app-sre`

This is the primary channel used to communicate with App SRE.  For immediate needs, use the `@app-sre-ic` handle to ping the App SRE engineer currently set as the "interrupt catcher".  If a question is not immediate in nature, please do not use the handle.

### `#team-insights-info`

app-interface is configured to send all saas-deploy notifications to this channel.  You can check this channel to see when a promtion to stage or prod completed and whether it was successful or not.

As teams become more familiar with the promotion flow, we can add team-specific channels for notifications to go to. 

### `#sd-app-sre-insights-alerts-stage`

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

1. Find the git commit from your source repo that you want to promote and copy the first seven characters, e.g `87ff3c59c94fe28d1d500a701d8acc2167cc7703` becomes `87ff3c5`.
2. Locate your app folder in app-interface, e.g. `data/services/insights/ingress` and open `deploy.yml` (also known as `saas.yml`).
3. For each `resourceTemplate` that uses your updated image, set the `IMAGE_TAG` parameter value to your seven character git commit hash.
4. Commit the change, push to your fork of app-interface, and open a merge request (MR).
5. App devs need to get an owner of your saas file to approve your changes (you cannot self-approve even if you are an owner).  The devtools bot should add a comment to your MR stating which users can approve.  The approver just needs to add a comment to the MR with the content `/lgtm`.  [Example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/5684).

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

To log into Vault, follow the instructions in [Vault's Readme](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/vault.md).

### Updating Vault Secrets

1. Log into Vault and make sure you're at the [root URL](https://vault.devshift.net/ui/vault/secrets).

2. Navigate to your secret within the UI:

    1. Click on `insights/secrets/` to get to where cloud.redhat.com secrets are stored.

    2. Click on `insights-prod/` or `insights-stage/`, depending on which environment's secrets you want to modify.

    3. Click on your app, and then click on the secret you want to update.

3. Click "Create new version +" in the top-right corner.

4. Set "Maximum Number of Versions" to 0, which removes the maximum. Make updates to your secret, and hit "Save".

5. Open an app-interface MR to update the secret's version number in your app's config.


### How to add a Grafana dashboard

1. Add (or update) the dashboard file (a ConfigMap containing the json data) in [saas-templates/dashboards](https://gitlab.cee.redhat.com/insights-platform/saas-templates/-/tree/master/dashboards). Each merge to this repository will deploy the dashboards to the [Grafana stage instance](https://grafana.stage.devshift.net/).

1. If this is a new dashbord:
  - Add the configmap as a volume and volumeMount to the grafana pod template in [the app-sre-observability repo](https://gitlab.cee.redhat.com/service/app-sre-observability/). An example of the changes can be found [here](https://gitlab.cee.redhat.com/service/app-sre-observability/commit/0bee8c95be4a27121e6b1ff82a75a2e01901a8f4)
  - Once the template changes are merged, the saas file hash for the grafana service should be bumped so the changes are deployed. This can be done in [saas-grafana](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-grafana.yaml)

1. To promote the dashboard changes to the [Grafana production instance](https://grafana.app-sre.devshift.net/), the saas file hash for the `insights-dashboards` should be bumped so the changes are deployed.
