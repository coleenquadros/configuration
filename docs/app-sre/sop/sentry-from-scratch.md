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

## Post installation tasks

Once the instance is up and running there are a few things that need to be done manually. The order is important because the database initialization step will create the administrative user, which is required to generate the auth token and enable SSO.  Likewise once SSO is enabled the administrative user will not be able to login.  It is recommended to create the auth token first, then enable SSO.

The task order is:

1. Initialize the database
2. Organization settings
3. Create the admin user's auth token
4. Enable SSO

### Initializing the database

The database initialization yaml is contained in the sentry repo (github.com/app-sre/sentry) and is named init-db.yaml.  This job will initialize the sentry database and create the administrative user.  To run this, ensure you are logged into the cluster and project where sentry is running.  Then run the following command:

oc process IMAGE_TAG=<image_tag> -f init-db.yaml | oc create -f -

It is best to use the same IMAGE_TAG as the sentry images deployed

There are a number of parameters that can be changed if needed that are defined in the template.

NOTE: This process can consume a LOT of memory.  The request limit in the job should be enough for the task to complete, but in case it is OOMKilled increase the memory limit, delete the database, and retry once it is re-created.

### Organization settings

There are a few configuration tasks that need to be done for the sentry organization to ensure team/issue isolation.  Ensure the following settings are configured in the organization general settings:

- Open Membership: Off
- Default Role: Member
- Allow Shared Issues: Off
- Require Data Scrubber: On
- Require Using Default Scrubbers: On

### Creating the admin user's auth token

Log in to sentry using the admin credentials in valut (SENTRY_INITIAL_EMAIL and SENTRY_INITIAL_PASSWORD).  Once logged in click on the user in the upper left corner and go to `User Settings`.  There should be an option named `Auth Tokens`.  Select it and in the upper right hand corner should be a button the says `Create New Token`. Click that button and make sure all scopes are checked before hitting the `Create Token` button.

Once the token has been created, it needs to be stored in vault (app-sre/creds) with the following key:

- auth_token

### Enabling SSO

First you need to create a new `OAuth App` in github.  Navigate www.github.com/app-sre and click on settings.  Under `Developer Settings` is an option for `OAuth Apps`.  Create a new OAuth App pointing the `Homepage URL` and `Authorization callback URL` to the new sentry instance.

Next, log into sentry using the admin credentials in valut (SENTRY_INITIAL_EMAIL and SENTRY_INITIAL_PASSWORD).  Once logged in click on the `Settings` option on the left.  From there click on the `Auth` option and click on the `Configure` button next to github.

Note: Once you log out of the sentry instance after SSO is enabled you will not be able to log back in as that user unless there is an associated github account for that user.  You can still log in via the django interface however (sentry.url/admin)
