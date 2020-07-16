# cloud.redhat.com Developer Onboarding

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
