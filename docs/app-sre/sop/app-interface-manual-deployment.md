# Manual deployment of App Interface bundle

 In case we have an outage with ci-int, merges to app-interface will not be deployed.

 In the case of such an outage, we can still merge to app-interface, but we will need to manually generate and upload the bundle to the S3 bucket.  From there, all (most) of our integrations will kick in, as they are running on our clusters.

 To manually generate and upload the bundle:

 1. Export each key in this secret as an environment variable: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface/production/s3:
    ```sh
    $ export VAULT_ADDR=https://vault.devshift.net
    $ vault login -method=github # enter your GH token
    $ ENV_VARS=$(vault read app-sre/creds/app-interface/production/s3 -format=json | jq -r ".data|to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
    $ for v in $ENV_VARS; do export $v; done
    ```
 2. Run `./hack/build_deploy.sh`.
