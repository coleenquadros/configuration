# Onboard a new GitHub organization to app-interface

To on-board a new GitHub org to app-interface, perform the following operations:

1. Invite the `app-sre-bot` [GitHub user](https://github.com/app-sre-bot) to the org as an Owner.
    * If you wish to use a different user instead of `app-sre-bot`, you first need to do:
        * Create the new user.
        * Create a new Personal Access Token as the new user. [link](https://github.com/settings/tokens)
        * Have that token stored in Vault.

2. Accept the invitation as `app-sre-bot`, by either:
    * Contact Jaime Melis to accept the invitation.
    * Sign in to GitHub using the `app-sre-bot` [credentials](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/github-app-sre-bot) and a Recovery code.
    * Add the GitHub org to app-interface (pending automation - https://issues.redhat.com/browse/APPSRE-936).

3. To add the GitHub org to app-interface, submit a merge request:
    * Add the GitHub org to app-interface:
        * `name` - the name of the GitHub org
        * `url` - GitHub url of the org (https://github.com/org-name)
        * `managedTeams` (optional) - If you do not wish to manage all the teams in the org, define only the teams you want to manage under this section
        * `token` -
            * `path` - path to secret in Vault (`<secret_engine_name>/path/to/secret`)
            * `field` - the key in the secret containing the token.
            * `format` (optional) - `plain` or `base64`. choose `base64` if the token is stored in Vault base64 encoded (defaults to `plain`).
            * `version` (optional) - if the secret engine is a v2 KV secret engine, specify the version of the secret to use.
                * [example](/data/dependencies/github/app-sre.yml#L11-13) for a token stored in a v1 KV secret engine.
                * [example](/data/dependencies/github/cs-sre.yml#L11-14) for a token stored in a v2 KV secret engine.
        * [example](/data/dependencies/github/app-sre.yml)
    * Create a new permission to allow adding users to this org. [example](/data/teams/app-sre/permissions/github-app-sre.yml)
    * Add the new permission to the `app-sre-bot` role. [example](/data/teams/app-sre/roles/app-sre-github-bot.yml#L8) and to other users as required.

4. To create teams in the GitHub org through app-interface, submit a merge request:
    * Create a new permission to allow adding users to this team:
        ```yml
        ---
        $schema: /access/permission-1.yml

        labels: {}

        name: github-example
        description: access to something using github auth

        service: github-org-team
        org: app-sre
        team: github-example
        ```
        * This example will create a team called `github-example` in the `app-sre` GitHub org.

    * Add the new permission to roles as required.
