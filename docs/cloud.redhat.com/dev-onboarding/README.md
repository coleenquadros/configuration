# cloud.redhat.com Developer Onboarding

- [Quick Links](#quick-links)
- [Accessing Stage Environment](#accessing-stage-environment)
- [Accessing Production Environment](#accessing-production-environment)
- [Connect with App SRE on Slack](#connect-with-app-sre-on-slack)
- [How to Promote an Image to Stage](#how-to-promote-an-image-to-stage)
- [How to Update the UI in Stage](#how-to-update-the-ui-in-stage)

## Quick Links

* [app-interface deep dive slides](https://docs.google.com/presentation/d/1R1JtB29TVnANfCoy_JOxVE5ehe_6cfiVdzRrQ468TIo/edit#slide=id.g782698ae7e_2_697)
* [app-interface deep dive recording](https://bluejeans.com/s/eLhjG)
* [Production promotion epic](https://projects.engineering.redhat.com/browse/RHCLOUD-5439): You can find your respective apps in that epic and follow along with the progress.
* [Visual App-Interface](https://visual-app-interface.devshift.net/)
* [Grafana](https://grafana.app-sre.devshift.net/dashboards): App SRE uses one Granfana for all clusters; each graph chooses the datasource by cluster.

## Accessing Stage Environment

* UI: https://cloud.stage.redhat.com
* Openshift console: visual-app-interface > Clusters > Search "crc" > Choose cluster that says "stage cluster"
* Prometheus: visual-app-interface > Clusters > Search "crc" > Choose cluster that says "stage cluster" > Details > Prometheus

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

**Insights Client Config**

NOTE:  This requires insights-client version 3.0.173+

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
