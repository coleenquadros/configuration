# App-interface Slack App

AppSREGroups is a Slack app that is used in app-interface integrations.

This SOP provides information on how it is configured.

## App manifest

With the new app-manifest API, we can explore automating the creation/update of this app: https://app.slack.com/app-settings/T027F3GAJ/AKCMUPYJ3/app-manifest

For now we will just keep the manifest for DR scenarios:

```yaml
_metadata:
  major_version: 1
  minor_version: 1
display_information:
  name: AppSREGroups
features:
  bot_user:
    display_name: app-sre-bot
    always_online: true
oauth_config:
  scopes:
    user:
      - channels:read
      - channels:write
      - usergroups:read
      - usergroups:write
      - users:read
    bot:
      - app_mentions:read
      - calls:read
      - calls:write
      - channels:history
      - channels:join
      - channels:read
      - chat:write
      - chat:write.customize
      - commands
      - dnd:read
      - files:read
      - groups:history
      - groups:read
      - groups:write
      - im:history
      - im:read
      - im:write
      - incoming-webhook
      - mpim:history
      - mpim:read
      - mpim:write
      - pins:write
      - reactions:read
      - reactions:write
      - remote_files:read
      - remote_files:share
      - remote_files:write
      - team:read
      - usergroups:read
      - usergroups:write
      - users:read
      - users:read.email
      - users:write
      - channels:manage
settings:
  org_deploy_enabled: false
  socket_mode_enabled: false
  token_rotation_enabled: false
```


## Slack usage across AppSRE tooling

### PagerDuty
- https://redhat.pagerduty.com/service-directory?direction=asc&query=&team_ids=PS6EEYR
### AlertManager (#sd-app-sre-alert)
- https://redhat-internal.slack.com/apps/A0F7XDUAZ-incoming-webhooks?tab=settings&next_id=0
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-input/alertmanager-integration
### Qontract-reconcile (cluster upgrades, jira, etc)
- https://app.slack.com/app-settings/T027F3GAJ/AKCMUPYJ3/app-manifest
- https://api.slack.com/apps/AKCMUPYJ3/oauth
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/app-interface (reconcile/triggers channel)
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre-stage/app-interface-stage/app-interface (reconcile/triggers channel stage)
### Jenkins
- https://ci.int.devshift.net/manage/configure
- https://ci.int.devshift.net/credentials/store/system/domain/_/credential/slack-integration-token/
- https://ci.ext.devshift.net/manage/configure
- https://ci.ext.devshift.net/credentials/store/system/domain/_/credential/slack-integration-token/
### Status page
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/status.redhat.com
- https://manage.statuspage.io/pages/dn6mqn7xvzz3/slack
- https://manage.statuspage.io/pages/8szqd6w4s277/slack
- https://redhat-internal.slack.com/services/B0CUC1N1Y
### Gitlab (#sd-app-sre-info)
- https://gitlab.cee.redhat.com/service/app-interface/-/settings/integrations/slack/edit
- https://gitlab.cee.redhat.com/service/dev-guidelines
- https://gitlab.cee.redhat.com/app-sre/infra
- https://gitlab.cee.redhat.com/service/app-sre-observability
- https://gitlab.cee.redhat.com/service/vault-devshift-net
- https://gitlab.cee.redhat.com/app-sre/contract
- https://redhat-internal.slack.com/apps/A0F7XDUAZ-incoming-webhooks?tab=settings&next_id=0
### Github
- https://github.com/organizations/app-sre/settings/installations/1177464
### Unleash
- https://app-interface.unleash.devshift.net/addons/edit/1
