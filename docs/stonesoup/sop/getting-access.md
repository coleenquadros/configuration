# Getting access to RHTAP systems for debugging

## General comments on App Interface merge requests

* App Interface is a very active repo. You may need to rebase your MR a few times until you get passing tests and the approvals you need (a `\lgtm` from the required approver or approvers).
* New users frequently forget to add the bot to their fork: `the user @devtools-bot is not a Maintainer in your fork of app-interface. Please add the @devtools-bot user to your fork as a Maintainer and retest by commenting "/retest" on the Merge Request.`
* Watch the bot-generated comments on your merge request to see what approvals you need, and from whom.  When you're requesting a role, you will generally need an approval from someone in the RHTAP team who already has that role.
* You can also reach out on #sd-app-sre-onboarding for help with getting your request approved, if it's urgent.
* Once the MR is approved, the bots will take over rebasing and getting it merged.

## General comments on AWS account access

* After the App Interface MR is merged, if you’re new to the AWS account, App Interface sends you an email with the subject “AWS Access provisioned” and your temporary password.
* You must update your password, enable MFA, log out and then log back in to use the console. Until then, you will see many red access-denied errors. Example of an error due to missing MFA: `User: arn:aws:iam::663944276957:user/jfischer is not authorized to perform: logs:DescribeLogStreams on resource: arn:aws:logs:us-east-1:663944276957:log-group:stonesoupp01ue1.argocd:log-stream: with an explicit deny in an identity-based policy`
* If you already have a userid in the AWS account from outside of App Interface, you will not be able to use App Interface to manage your AWS account access. (This usually only applies to the account owner.)
* If you need to reset your password for an account managed by App Interface: (https://gitlab.cee.redhat.com/service/app-interface#reset-aws-iam-user-passwords-via-app-interface)

## Gain view access to RHTAP logs

### Request access via App Interface

* To get access to RHTAP cluster logs in Cloudwatch, your app-interface user should have to stonesoup-dev-aws role: [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/stonesoup/users/gbenhaim.yml#L17)

### Steps

* Log into the [Stonesoup AWS logging account](https://520050076864.signin.aws.amazon.com/console)
* Browse to [cloudwatch](https://console.aws.amazon.com/cloudwatch/home)
* Select a logging group, formatted as `<cluster>.<namespace>`.

## Gain view access to AppSRE logs, including logs from the fleet manager cluster and ArgoCD

### Request access via App Interface

* [Gain access to view cloudwatch logs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/FAQ.md#get-access-to-cluster-logs-via-log-forwarding)
* To get access to logs for the fleet management cluster, your app-interface user should have the log-consumer role: [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/stonesoup/users/gbenhaim.yml#L16)

### Steps

* Log into the [AppSRE AWS logging account](https://744086762512.signin.aws.amazon.com/console)
* Browse to [cloudwatch](https://console.aws.amazon.com/cloudwatch/home)
* Select a logging group, formatted as `<cluster>.<namespace>`. The RHTAP fleet manager is hosted on cluster stonesoupp01ue1.
  
## Manage RHTAP deployments using Argo CD on the fleet manager cluster

### Request access via App Interface

* To get access to Argo CD, your app-interface user should have the stonesoup role: [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/stonesoup/users/gbenhaim.yml#L12)

### Steps

* Log into the [Argo CD dashboard](https://argocd-server-argocd.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/applications)
* Find each failing component and click through to check its status and logs.

## Add or update secrets in the AppSRE Vault

### Request access via App Interface

* If you need to add new secrets the the AppSRE vault, then your app-interface user should have the stonesoup-vault and visual-app-interface roles: [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/stonesoup/users/gbenhaim.yml#L13)
* Refer to the [Secrets SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/secrets.md) for more details.

### Steps

* Once you have access, you can go to the [Vault console](https://vault.devshift.net/ui/vault/secrets/stonesoup/list?page=1) to add or update secrets.

## Gain view access to RHTAP clusters

We can grant users view-everything access to the RHTAP clusters by adding them to the appropriate group in Github.

### Request access via Slack

* Post your request for developer access to the clusters on the #wg-stonesoup-platform channel, including your Github ID
* Your Github ID must have your @redhat.com email address associated with it (although it doesn't have to be the primary email address).
* You just have 2FA enabled.
* You will receive an invitation via email or the Github UI to either the "sre" or "stage" team.
* After accepting the team membership, you will be able to log in to the cluster consoles using your Github credentials.

## Gain view access to the fleet manager cluster

### Request access via App Interface
* TODO - which roles grant this access?
* You will receive an invitation via email or the Github UI to the "app-sre" team.
* After accepting the team membership, you will be able to log in to the cluster consoles using your Github credentials.

### Access the OpenShift console
* The OpenShift console for our fleet manager cluster is at (https://console-openshift-console.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/)

### Verify Argo CD access for another user
* `oc get rolebinding view-<userid> -o yaml apiVersion: rbac.authorization.k8s.io/v1`
