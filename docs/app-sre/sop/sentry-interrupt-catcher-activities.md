# Sentry Interrupt Catcher Activities

## Background

Sentry is an error tracking/management service.  Applications import a sentry SDK and augment their code with calls to send errors to a project in sentry.  The sentry SDK must be initialized with the DSN for the project that will receive the data.

Sentry projects are associated to a team in sentry, and members of a team are able to access all data in all projects associated with that sentry team.  We have sentry configured such that users are only able to see projects that are associated to the teams where they have membership.  This is done to keep team/project data isolated from other teams since we are managing a shared instance used by multiple teams.

Creation of sentry teams, projects, and users are all handled through app-interface.  If a user attempts to log into sentry without creating a necessary configuration in app-interface then their account will be deleted the next time the integration is run.

Sentry is configured to use Single Sign-On via Github OAuth.  Any mention of SSO in this document refers to this type of setup and only this setup.

## URLs

[stage](https://sentry.stage.devshift.net/)

[production](https://sentry.devshift.net/)

## App-Interface docs

[creating a project](https://gitlab.cee.redhat.com/service/app-interface#create-a-sentry-project-for-an-onboarded-app-app-sreapp-1yml)

[creating a team](https://gitlab.cee.redhat.com/service/app-interface#create-a-sentry-team-dependenciessentry-team-1yml)

[associating user to team](https://gitlab.cee.redhat.com/service/app-interface#manage-sentry-team-membership-via-app-interface-accessrole-1yml)

## User management

Sentry is configured to use Single Sign-On via Github OAuth.  Anyone who is part of the app-sre team in github is able to log into sentry, and sentry will create an account for them.  This actually causes a number of annoying problems stemming from either a lack of an app-interface controlled account to duplicate accounts.

### Lack of sentry account

This can happen for a number of reasons:

- User doesn't have correct sentry configuration in app-interface
- User doesn't have a public primary e-mail address configured on their github account

In these cases the user will still be able to log into sentry, but will not have the correct permissions or be part of a team.  This usually results in the user attempting to request access to the team they are interested in joining and an e-mail being generated requesting access.  Since the sentry integration doesn't know about the user account that was just added it will be deleted when the integration is next run.  This usually results in the user trying again, another e-mail generated, rinse, repeat.

The solution is to solve the lack of app-interface controlled sentry account.  The user needs to have a role that includes sentry_teams in it for the integration to know about the user.

For an account to actually be created, the user must have a public e-mail address set on their github account.  This public e-mail should be their primary e-mail address as that is the e-mail that will be used by the SSO system.  The user needs to have the the primary e-mail set as their public email in their profile (settings->proflile) and be visible (settings->emails).

### Duplicate accounts

This occurs because sentry isn't great about always associating a new login with an account we have already created through the integration.  What happens is a user attempts to log into sentry, but sentry doesn't associate the existing account with the user logging in and creates a new account for them.  This account won't be part of any of the teams in sentry and thus can't really do anything.

The integration should handle this situation without any intervention.  However, if for some reason the integration doesn't fix this situation then what is happening is that then integration is managing the account it created while ignoring the account that sentry created on its own.  The solution is to delete the account created by the integration.  The next time the integration runs it will find the account with the expected e-mail address and set the permissions and team membership correctly and manage that account as if it had created it.

You can identify the account that has NOT been logged into because it will usually be only the e-mail address (instead of the user's name and e-mail) and will have `Invited` text with a link to `Resend Invite` or `Expired` text next to it.

## Requests to join a team

There are instances when a user doesn't have a correctly configured account and they try to request membership to their team in sentry.  This results in an e-mail being generated to the admin user with the subject `Sentry Access Request`.  These e-mails/requests should be ignored and the user directed to make the appropriate changes in app-interface, make their primary e-mail public, or have their duplicate account deleted.

## Admin interface

Sentry is built on top of django, so that means there is a adminitrative login at `url/admin`.  Unlike the usual sentry login when SSO is enabled, this login allows username/password and will accept the admin credentials listed in vault (app-sre[-stage]/sentry-[production|stage]/sentry-init).

This interface doesn't give you complete control over all of sentry, but it does allow you to do some basic tasks like delete users, add/remove users from the sentry organization, and basic editing.

### Fixing SSO user associations

This should probably never happen to most people, but it is possible for your github credentials to be associated with an account other than yours.  This usually can happen if you have logged into sentry using a login/password combination for a user OTHER than the e-mail primary e-mail address associated with your github account, and then enable SSO in sentry.  It seems the token left in your browser, even after you log out, will still connect you to the last account you used when you logged into sentry, and when you log in via SSO it will connect your github id to that sentry account.

The fix for this is 2 fold.  First you log into the admin interface and go to the list of users.  Find the e-mail address/account in sentry you are logging in as, and click on it for details.  Scroll to the bottom and there should be an `Auth identitys` section with an entry for github.  Check the box on the far right and click save to delete it.  Then log out of the admin interface and clear all the cookies in your browser.  In theory you can probably clear only the sentry cookies.  Make sure you delete ALL the cookies, not just ones created recently.  Then, log back into sentry via SSO and it should associate with the correct account.  If not, you probably have a new accounted created and will need to go into the admin interface again to delete the excess account and let the integration fix the permissions.

The duplicate account will be the account with your e-mail address but will NOT have the github auth provider configured.

## How to find the DSN

The DSN is a unique string used by the sentry SDK to direct events to a specific project in sentry.  It is located in the settings of the sentry project under the `SDK Setup` section.  There is a link named `Client Keys (DSN)`.  You want the value listed as `DSN` not the `DSN (Deprecated)` one.

## How to solve events not appearing

This is likely because the sentry-cron and/or sentry-worker pods had a problem contacting the DB.  It seems when this happens the print a traceback in their log files and then continue running.  There's no external indication that there is a problem other than that events aren't getting recorded.  This can be discovered by looking the pod logs and searching for a traceback.  The error will likely report a problem contacting/resolving the DB.  The fix is just to delete the pod and let it be restarted.  If one of th pods has the error it is likely the other one does as well so it's probably best to just delete both pods.

## Sentry isn't receiving data

Sentry has pretty terrible error handling.  It will dump backtraces into log files, and then happily try to continue on instead of exiting/crashing.  What's worse is if the error is because of an inability to access a part of sentry, like the DB or redis, it will be unable to access the resource in the future.  This basically means sentry errors are hidden from us and we can't rely on an automated pod crash/restart to fix things.

If this occurs then there are likely errors/backtraces in the pod logs.  Look in the logs of the sentry-web and sentry-worker pods:

```shell
oc get pods
oc logs sentry-web-<id>
oc logs sentry-worker-<id>
```

To fix this, restart the sentry-cron, sentry-web, sentry-worker, and redis pods in the namespace:

```shell
oc delete pod redis-<id> sentry-cron-<id> sentry-web-<id1> sentry-web-<id2> sentry-worker-<id>
```

Then log into the sentry instance UI and into projects to see that events are being received.  Do this by logging into sentry and clicking on `Settings` on the left side then choose `Projects`.  Choose a project and look at the events to see when it was last seen.  This is shown underneath the issue title next to an icon of a clock.  Clicking on an issue will also show more details for that issue, and on the right hand side is a field "LAST SEEN".

