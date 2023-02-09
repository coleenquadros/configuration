# Manual deployment of App Interface bundle

## ci-int outage

 Merges to app-interface will not be deployed if ci-int is down.

 In the case of such an outage, we can still merge to app-interface, but we will need to manually generate and upload the bundle to the S3 bucket.  From there, all (most) of our integrations will kick in, as they are running on our clusters.

 To manually generate and upload the bundle:

 1. Export each key in this secret as an environment variable: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface/production/s3:
    ```sh
    $ export VAULT_ADDR=https://vault.devshift.net
    $ vault login -method=oidc
    $ ENV_VARS=$(vault read app-sre/creds/app-interface/production/s3 -format=json | jq -r ".data|to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
    $ for v in $ENV_VARS; do export $v; done
    ```
 2. Run `./hack/build_deploy.sh`.

## GitLab webhooks delayed / not working

You can determine if the webhooks for ci-int are broken by viewing the [webhook settings page](https://gitlab.cee.redhat.com/service/app-interface/-/hooks). Click **Edit** on one of the webhooks and view the list of recent events. If there aren't any recent events, and there are MRs without pipelines running, then it's likely that the webhooks are queued on the GitLab side.

If there are emergency merges that need to happen, after merging manually via the GitLab UI, you should manually run the Jenkins job associated with the webhooks (deploy to stage/prod). This is what triggers app-interface to upload the bundle to S3, so app-interface changes will not take effect without manually running these jobs. PR checks will be blocked until GitLab webhooks are being sent again.

### Other helpful info
- Webhook calls appear to be queued for some reasonable period of time (we've observed 4+ hours)
- Clicking the 'Test' button on the webhook has worked in the past even when all other webhook calls are otherwise delayed. It appears that internally there may be a different mechanism for handling these test webhooks. We shouldn't accept these test events as proof that there isn't an issue on the GitLab side.
