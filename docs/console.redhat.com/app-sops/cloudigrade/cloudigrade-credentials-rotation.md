# cloudigrade credentials rotation

## Summary

This document includes systems and configs *not* managed by Red Hat SSO or SRE/app-interface that the cloudigrade dev team maintains.

If shared memberships or credentials for cloudigrade need updating, such as when a team member with privileged access leaves, the cloudigrade dev team should follow the steps outlined in this document to update memberships and rotate credentials. These steps may not be exhaustive but cover all known aspects at the time of this writing. We do not have automation to perform these changes; we may build some if the cloudigrade dev team experiences increased turnover.

## Various external org memberships

- GitHub.com org membership
  - go to https://github.com/orgs/cloudigrade/people
  - user cog: remove from organization
- GitLab.com org membership
  - go to https://gitlab.com/groups/cloudigrade/-/group_members
  - remove member, and check all boxes
- Sentry.io membership
  - go to https://sentry.io/settings/cloudigrade/members/
  - click remove button
- Azure directory and subscription access
  - go to https://portal.azure.com and log in using your `@redhat.com` email address to use Red Hat SSO
    - If your SSO user does not have access to all cloudigrade directories, use the `@outlook.com` login that is the original owner of the cloudigrade directories.
  - For each directory here https://portal.azure.com/#settings/directory
    - click "Switch"
    - go to "Users" https://portal.azure.com/#view/Microsoft_AAD_IAM/UsersManagementMenuBlade/~/MsGraphUsers
    - Select and delete only "Guest" type users, *NOT* "Member" type users
      - the user's "principal name" should contain `_redhatcom#EXT#@`
      - the user's "Identity issuer" should be `ExternalAzureAD`
    - Azure user management is buggy. If you refresh the users list, the deleted user may disappear and reappear again several times before permanently disappearing. *shrug*
- Docker Hub org membership
  - cloudigrade no longer pushes images to Docker Hub, but we did previously, and we still have an org there.
  - log in as owner and go to [Cloudigrade members](https://hub.docker.com/orgs/cloudigrade)
  - identify old members, and use the kebab menu's "Remove member"

## Sentry.io keys (DSNs)

- go to each project's keys:
  - https://sentry.io/settings/cloudigrade/projects/cloudigrade-api/keys/
  - https://sentry.io/settings/cloudigrade/projects/cloudigrade-celery/keys/
  - https://sentry.io/settings/cloudigrade/projects/cloudigrade-listener/keys/
  - https://sentry.io/settings/cloudigrade/projects/houndigrade/keys/
- For each project,
  - DO NOT deactivate the old keys yet.
  - click "Generate New Key"
  - configure to give it a reasonable name like "red-hat-prod-20220531"
  - update vault.devshift.net with new DSNs:
    - [cloudigrade-stage/cloudigrade-aws](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-stage/cloudigrade-stage/cloudigrade-aws)
    - [cloudigrade-prod/cloudigrade-aws](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/cloudigrade-prod/cloudigrade-aws)
  - update the relevant secret versions in app-interface:
    - [stage-cloudigrade-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/stage-cloudigrade-stage.yml)
    - [cloudigrade-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/cloudigrade-prod.yml)
  - get someone in SRE to approve your MR; you can't just `/lgtm` changes to namespace files like this.
  - force stage and prod to redeploy since changing the secret version doesn't seem to do it
    - like [this example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/40010/diffs)
  - confirm that the new key's DSN is being used
  - disable and delete the old key(s)

## Microsoft Outlook account (root owner of Azure directories)

- Microsoft Outlook password and primary email address
  - https://account.microsoft.com/profile/
  - "Change password" top right of page
  - "Edit account info" to change primary email address
- update/replace email-based MFA/2FA
  - https://account.live.com/proofs/manage/additional
  - "Add a new way to sign in or verify" at bottom of list
  - "Email a code", enter your actual `@redhat.com` address
  - Be patient. It took a minute for my emailed code to arrive.
  - "Remove" any old email addresses *after* completing the new address

## AWS security and access keys

- For *each* AWS account (yes, all 14 of them):
  - go to [IAM: Users](https://us-east-1.console.aws.amazon.com/iamv2/home#/users) and remove any inactive users
  - update keys for the `cloudigrade-reaper` user.
    - go to [IAM: Users: cloudigrade-reaper: Security credentials](https://us-east-1.console.aws.amazon.com/iam/home#/users/cloudigrade-reaper?section=security_credentials)
    - DO NOT deactivate the old access keys yet.
    - click "Create access keys"
    - update [reaper secrets in GitHub](https://github.com/cloudigrade/reaper/settings/secrets/actions)
    - confirm the reaper actions succeed (see recent [GitHub workflow runs](https://github.com/cloudigrade/reaper/actions) and rerun manually if necessary)
    - confirm that the old keys are not being used by comparing the "Last used" dates on [AWS Security credentials](https://us-east-1.console.aws.amazon.com/iam/home#/users/crc-ephemeral?section=security_credentials).
    - click "Make inactive" for old keys, and then click "x" to delete.
  - go to [EC2: Network & Security: Key Pairs:](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:)
    - delete, and recreate only if needed
    - update launch configurations to use new keys if necessary
    - redeploying cloudigrade (specifically: running the ansible playbook) will recreate required keys
      - you may need to trigger stage and prod deployments *immediately* after deleting the old keys to ensure new inspection instances don't fail
    - repeat this for other regions (not just `us-east-1`)
  - go to [EC2: Network & Security: Security Group](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:)
    - delete, and recreate only if needed
    - review incoming and outgoing access to any that you keep (like the default SG)
    - update launch configurations to use different SGs if necessary
    - repeat this for other regions (not just `us-east-1`)

- In the shared AWS account (`372779871274`) for IAM user `crc-ephemeral`:
  - go to [IAM: Users: crc-ephemeral: Security credentials](https://us-east-1.console.aws.amazon.com/iam/home#/users/crc-ephemeral?section=security_credentials)
  - DO NOT deactivate the old access keys yet.
  - click "Create access keys"
  - update [ephemeral secrets in vault.devshift.net](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/ephemeral/cloudigrade/cloudigrade-aws)
  - update the relevant secret versions in app-interface:
    - [ephemeral-base.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ephemeral/namespaces/ephemeral-base.yml)
    - [crcd-ephemeral-base.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ephemeral/namespaces/crcd-ephemeral-base.yml)
  - confirm a new ephemeral environment deployment uses the new AWS access keys to communicate successfully with AWS
  - confirm that the old keys are not being used by comparing the "Last used" dates on [AWS Security credentials](https://us-east-1.console.aws.amazon.com/iam/home#/users/crc-ephemeral?section=security_credentials).
  - click "Make inactive" for old keys, and then click "x" to delete.

- In the stage+prod AWS account (`998366406740`) for IAM users "stage-cloudigrade" and "prod-cloudigrade":
  - go to [IAM: Users](https://us-east-1.console.aws.amazon.com/iamv2/home#/users) and edit the user
  - DO NOT deactivate the old access keys yet.
  - click "Create access keys"
  - update vault.devshift.net with new AWS access keys:
    - [cloudigrade-stage/cloudigrade-aws](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-stage/cloudigrade-stage/cloudigrade-aws)
    - [cloudigrade-prod/cloudigrade-aws](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/cloudigrade-prod/cloudigrade-aws)
  - update the relevant secret versions in app-interface:
    - [stage-cloudigrade-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/stage-cloudigrade-stage.yml)
    - [cloudigrade-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/cloudigrade-prod.yml)
  - get someone in SRE to approve your MR; you can't just `/lgtm` changes to namespace files like this.
  - force stage and prod to redeploy since changing the secret version doesn't seem to do it
    - like [this example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/40010/diffs)
  - confirm the new deployment uses the new AWS access keys to communicate successfully with AWS
  - confirm that the old keys are not being used by comparing the "Last used" dates on:
    - [IAM: Users: stage-cloudigrade: Security Credentials](https://us-east-1.console.aws.amazon.com/iam/home#/users/stage-cloudigrade?section=security_credentials): Access Keys: Last used
    - [IAM: Users: prod-cloudigrade: Security Credentials](https://us-east-1.console.aws.amazon.com/iam/home#/users/prod-cloudigrade?section=security_credentials): Access Keys: Last used
  - click "Make inactive" for old keys, and then click "x" to delete.

## Azure subscription application keys

- For each directory here https://portal.azure.com/#settings/directory
  - click "Switch"
  - go to [App Registrations](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
  - click "All applications" (default view is usually "Owner applications" which may not show everything)
  - for apps with shared credentials (ephemeral, stage, prod):
    - click the app
    - go to "Certificates & secrets" in the left nav
    - DO NOT delete the old secrets/keys yet.
    - click "New secret"
      - give it a reasonable name like "cloudigrade-ephemeral-20220601"
      - and a reasonably distant expiration
    - Note the Azure key's "value" goes into cloudigrade's vault as `client_secret`.
    - if secret is for the ephemeral environment:
      - update [cloudigrade-azure](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/ephemeral/cloudigrade/cloudigrade-azure)
      - update the relevant secret versions in app-interface:
        - [ephemeral-base.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ephemeral/namespaces/ephemeral-base.yml)
        - [crcd-ephemeral-base.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ephemeral/namespaces/crcd-ephemeral-base.yml)
      - confirm a new ephemeral environment deployment uses the new Azure secrets
      - delete the old azure secrets
    - else, for prod or stage secrets:
      - update vault.devshift.net with new Azure keys:
        - [cloudigrade-stage/cloudigrade-azure](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-stage/cloudigrade-stage/cloudigrade-azure)
        - [cloudigrade-prod/cloudigrade-azure](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/cloudigrade-prod/cloudigrade-azure)
      - update the relevant secret versions in app-interface:
        - [stage-cloudigrade-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/stage-cloudigrade-stage.yml)
        - [cloudigrade-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/cloudigrade-prod.yml)
      - get someone in SRE to approve your MR; you can't just `/lgtm` changes to namespace files like this.
      - force stage and prod to redeploy since changing the secret version doesn't seem to do it
        - like [this example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/40010/diffs)
      - confirm that the new Azure secrets are being used
      - delete the old Azure secrets


## Slack incoming message webhook

cloudigrade's ansible playbook notifies Slack using a configured URL (like `https://hooks.slack.com/services/0000/0000/0000`) when it runs.

- generate the actual token for Slack
  - TBD how to do this because Slack appears not to support legacy token regeneration.
  - TBD do we need to build and register an app for this?
- update vault.devshift.net with new `"slack-token"` value:
  - [cloudigrade-stage/cloudigrade-aws](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-stage/cloudigrade-stage/cloudigrade-aws)
  - [cloudigrade-prod/cloudigrade-aws](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/cloudigrade-prod/cloudigrade-aws)
- update the relevant secret versions in app-interface:
  - [stage-cloudigrade-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/stage-cloudigrade-stage.yml)
  - [cloudigrade-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/cloudigrade-prod.yml)
- get someone in SRE to approve your MR; you can't just `/lgtm` changes to namespace files like this.
- force stage and prod to redeploy since changing the secret version doesn't seem to do it
  - like [this example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/40010/diffs)
- confirm that the new Slack token is being used
- delete the old Slack token
