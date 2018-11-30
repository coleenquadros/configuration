#!/bin/bash

set -e

# Required secrets:
#
# - AWS_ACCESS_KEY_ID: aws credentials key id
# - AWS_SECRET_ACCESS_KEY: aws credentials secret access key
# - AWS_S3_BUCKET: bucket to access
# - AWS_S3_KEY: file to upload
# - USERNAME: username for app-interface.devshift.net
# - PASSWORD: password for app-interface.devshift.net

# https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-s3-production
# https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-basic-auth-prod

# Install required pip modules
rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

./pack-datafiles.py data > ${AWS_S3_KEY}

aws s3 cp ${AWS_S3_KEY} s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}
curl -u "${USERNAME}:${PASSWORD}" https://app-interface.devshift.net/reload

exit 0
