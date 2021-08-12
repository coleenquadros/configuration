# 3scale Config Promotion in app-interface

## Prerequisites

### Access to the following is required:
- https://gitlab.cee.redhat.com/abellott/insights-3scale-config (config source of truth)
- https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-stage/3scale-stage/apicast-insights-3scale-config (stage config secret)
- https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/3scale-prod/apicast-insights-3scale-config (prod config secret)

### Access to the following is optional:
- https://github.com/RedHatInsights/insights-3scale-docs (gateway config documentation)
- https://github.com/RedHatInsights/insights-3scale (gateway code repo with scripts)

_The following steps assume the config in https://gitlab.cee.redhat.com/abellott/insights-3scale-config has already been updated via the documented process here: https://github.com/RedHatInsights/insights-3scale-docs/blob/master/doc/build_deployment.md#examples and is ready to be pulled from the [config repo](https://gitlab.cee.redhat.com/abellott/insights-3scale-config) and promoted to stage/prod._

## Updating Config

### Get the latest
- pull the latest config from the [config repo](https://gitlab.cee.redhat.com/abellott/insights-3scale-config)
- the file you're interested in is `config/insights_3scale.json`

### Update Vault
- you'll need to access either the [stage](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-stage/3scale-stage/apicast-insights-3scale-config) or [prod](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/3scale-prod/apicast-insights-3scale-config) config secret
- toggle the "JSON" button to view the secret as JSON
- copy the data (_only the value_) for the key "insights_3scale.json" and store it locally as `updated_insights_3scale.json`

**Note:** _since the config repo currently stores **ALL** environments' config in `insights_3scale.json`, we need to cherry-pick the changes specific to the environment we're updating so we don't include other environments' config._

- ensure the your local `config/insights_3scale.json` file from the config repo is formatted the same as your data copied from Vault in `updated_insights_3scale.json` (_you may need to parse the Vault JSON_)
- do a diff on the two files, and add only the changes for your target environment in `updated_insights_3scale.json`
- reformat `updated_insights_3scale.json` as JSON
- copy the JSON from `updated_insights_3scale.json`
- in Vault, click "Create new version"
- in the value for the "insights_3scale.json" key, paste your copied JSON
- save the secret and note the version

### Update app-interface
- for [stage](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/gateway/namespaces/stage-3scale-stage.yml) or [prod](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/gateway/namespaces/3scale-prod.yml), bump the `version` for the `insights/secrets/insights-prod/3scale-prod/apicast-insights-3scale-config` secret entry

### Notes/TODO
Currently this is a very manual process, and we're using parts of an automated process which worked well for the DEV cluster (CI/QA) instances of the gateway. We were able to run scripts from our [gateway repo](https://github.com/RedHatInsights/insights-3scale) directly into OpenShift in order to update the secrets, so there was no manual intervention or risk of updating the secrets incorrectly.

Now, with the need to manually update Vault with the config per environment, it's extremely important that the JSON is validated before the secret is updated to ensure it's formatted as valid JSON, and that the diff going in only has the changes you require for that environment.

Moving forward, we should look at how we can use our source of truth for the config (ideally we'd have this more self-service) to hook into an update in Vault, without manual intervention. Or at the very least, have a script we can use to run these updates.
