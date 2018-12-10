#!/bin/bash

set -xv

# Required secrets:
#
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - CONFIG_TOML

# https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-s3-staging
# https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml

source ./.env

# variables
RESULTS=reports/results.json
REPORT=reports/index.html

AWS_S3_BUCKET=app-interface-staging
DATA_JSON=data-`date +%s`.json
AWS_REGION=us-east-2

# Download schemas
rm -rf schemas
curl -sL ${SCHEMAS_REPO}/archive/${SCHEMAS_REPO_COMMIT}.tar.gz | \
  tar -xz --strip-components=1 -f - '*/schemas'

# Run validation and generate report
docker run --rm \
  -v `pwd`:/data:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} > ${RESULTS}

exit_status=$?

# Install required pip modules
rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# generate report
python gen-report.py ${RESULTS} > ${REPORT}
echo "Report written to: ${REPORT}"

if [ "$exit_status" != "0" ]; then
  exit $exit_status
fi

# pack the datafiles and upload to s3
./pack-datafiles.py data > ${DATA_JSON}
aws s3 cp ${DATA_JSON} s3://${AWS_S3_BUCKET}

# write .env file
cat <<EOF > .env
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION=${AWS_REGION}
AWS_S3_BUCKET=${AWS_S3_BUCKET}
AWS_S3_KEY=${DATA_JSON}
EOF

# start graphql-server locally
qontract_server=$(
  docker run --rm -d \
    --env-file=.env \
    quay.io/app-sre/qontract-server:$SCHEMAS_REPO_COMMIT
)

# get network conf
IP=$(docker inspect \
      -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
      ${qontract_server})

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d | \
  sed "s/localhost/${IP}/" > config/config.toml

# run integrations
sleep 20

docker run --rm \
  -v `pwd`/config:/config:z \
  ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
  reconcile --config /config/config.toml github --dry-run \
  |& tee reports/reconcile-github.txt

# stop qontract-server
docker stop ${qontract_server}

# remove file from s3
aws s3 rm s3://${AWS_S3_BUCKET}/${DATA_JSON}
