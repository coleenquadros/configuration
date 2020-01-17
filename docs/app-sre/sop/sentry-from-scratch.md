# Creating a new sentry instance from scratch

To deploy a new instance of sentry via app-interface you'll need to create the yaml files similar to:

- data/services/sentry/namespaces/sentry-stage.yaml
- resources/app-sre-stage/sentry-stage/sentry/sentry.configmap.yaml
- resources/app-sre-stage/sentry-stage/sentry/sentry.route.yaml

To manage teams/projects/users you'll need to create a sentry instance yaml:

- data/dependencies/sentry/sentry-stage.yml

And lastly to create/manage teams you'll need to create a team file that references which sentry instance will contain the team:

- data/dependencies/sentry/teams/app-sre-stage.yml

You can control which users are part of which teams by adding a sentry_teams list to a role yaml file.  An example is [here](/data/teams/app-sre/roles/app-sre.yml)

In addition to the yaml files in app-interface needed to create a new service/instance of sentry you'll also need to create the following secrets in vault with the following keys:

- sentry-general
  - SENTRY_ENABLE_EMAIL_REPLIES (most likely should be `false`)
  - SENTRY_FILESTORE_DIR (use `/tmp/sentry-files` w/o external storage)
  - SENTRY_SECRET_KEY (can generate with `docker run --rm -it quay.io/app-sre/sentry sentry config generate-secret-key`)
- sentry-github-oauth (contains the github auth info for sso)
  - GITHUB_API_SECRET (`Client Secret` Client Secret github `oauth app` settings)
  - GITHUB_APP_ID (`Client ID` in github `oauth app` settings)
- sentry-init (Contains the login information for the admin user)
  - SENTRY_INITIAL_EMAIL (usually `sd-app-sre@redhat.com`)
  - SENTRY_INITIAL_PASSWORD (can be generated with `pwgen -cnysBv 16 1`)

You'll also need to create a secret with credentials for the integration to talk to the sentry instance (app-sre/creds).  This can't be done until the sentry instance is running, and needs to have the following key:

- auth_token (SENTRY_INITIAL_EMAIL user's auth token)

## Post installation tasks

Once the instance is up and running there are a few things that need to be done manually.

### Creating the admin user's auth token

Log in to sentry using the admin credentials in valut (SENTRY_INITIAL_EMAIL and SENTRY_INITIAL_PASSWORD).  Once logged in click on the user in the upper left corner and go to `User Settings`.  There should be an option named `Auth Tokens`.  Select it and in the upper right hand corner should be a button the says `Create New Token`. Click that button and then place the key generated into the valut secret used for the integration credentials.

### Enabling SSO

Log in to sentry using the admin credentials in valut (SENTRY_INITIAL_EMAIL and SENTRY_INITIAL_PASSWORD).  Once logged in click on the `Settings` option on the left.  From there click on the `Auth` option and click on the `Configure` button next to github.

Note: Once you log out of the sentry instance after SSO is enabled you will not be able to log back in as that user unless there is an associated github account for that user.  You can still log in via the django interface however (sentry.url/admin)
