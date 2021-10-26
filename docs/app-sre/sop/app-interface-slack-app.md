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
