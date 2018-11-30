#!/bin/bash

# Required secrets:
#
# - AWS_ACCESS_KEY_ID: key to upload file to s3 bucket
# - AWS_SECRET_ACCESS_KEY: secret key to upload file to s3 bucket
# - USERNAME: username for app-interface.devshift.net
# - PASSWORD: password for app-interface.devshift.net

# https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-s3-production
# https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-basic-auth-prod

BUCKET=app-interface-production
FILE=data.json

aws s3 cp ${FILE} s3://${BUCKET}/${FILE}
curl -u "${USERNAME}:${PASSWORD}" https://app-interface.devshift.net/reload

exit 0
