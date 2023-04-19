# Onboard a new Quay organization to app-interface

To on-board a new Quay org to app-interface, perform the following operations:

1. Create an automation token for this org. 
    * Since tokens in quay are tied to the person who created them, we suggest using bot account, either yours or ours [sd_app_sre_quay_bot](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-quay-bot). Invite bot to the quay-org and login as bot.
    * Go to `Applications` in Quay (https://quay.io/organization/**my-quay-org**?tab=applications).
    * Create an application called `automationToken`.
    * Generate a token for the application with `Administer Organization` permissions and have it stored in Vault (include `Administer Repositories` if you need to config repository with [team permissions](https://gitlab.cee.redhat.com/service/app-interface#create-a-quay-repository-for-an-onboarded-app-app-sreapp-1yml)).

2. To add the Quay org to app-interface, submit a merge request:
    * Add the Quay org to app-interface:
        * `name` - the name of the Quay org
        * `managedTeams` - a list of teams to manage in the org.
            * teams should be created manually
            * the automation only adds/removes users to/from teams.
        * `automationToken` -
            * `path` - path to secret in Vault (`<secret_engine_name>/path/to/secret`)
            * `field` - the key in the secret containing the token.
            * `format` (optional) - `plain` or `base64`. choose `base64` if the token is stored in Vault base64 encoded (defaults to `plain`).
            * `version` (optional) - if the secret engine is a v2 KV secret engine, specify the version of the secret to use.
        * [example](/data/dependencies/quay/app-sre.yml)
    * Create new permissions to allow adding users to teams in this org. [example](/data/dependencies/quay/permissions/quay-membership-app-sre-telemeter.yml)
    * Add the new permissions to roles as required.
    * Add role to users, including the bot user.
    * [example MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/26367)

## Pushing and pulling images during CI

3. Create 2 Robot accounts:
    - name: `deployer`
      description: `CI deployer`
      permissions: Read access to all repositories (should be defined using Default Permissions)
      secret name to create in Vault: <quay-org-name>-pull
    - name: `push`
      description: `Account with push privileges, for CI`
      permissions: Write access to all repositories (should be defined using Default Permissions)
      secret name to create in Vault: <quay-org-name>-push

4. Store the following details for each of the 2 Robot accounts in Vault:
    * For each Robot account, create a secret in Vault according to the `secret name to create in Vault` mentioned above, with the following keys:
        * `config.json` - a base64 encoded Docker configuration file
        * `token` - the Robot token
        * `user` - <quay-org-name>+name (e.g. app-sre-deployer)
    * These secrets will be used by Jenkins job definitions. [example](/resources/jenkins/common/secrets.yaml#L10-30)
