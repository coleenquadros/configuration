#!/bin/bash

set -e

source ./.env

wait_response() {
    local count=0
    local max=10

    URL=$1
    EXPECTED_RESPONSE=$2

    while [[ ${count} -lt ${max} ]]; do
        let count++
        RESPONSE=$(curl -sf $URL)
        [[ "$EXPECTED_RESPONSE" == "$RESPONSE" ]] && break || sleep 10
    done

    if [[ "$EXPECTED_RESPONSE" != "$RESPONSE" ]]; then
      echo "Invalid response." >&2
      echo "Expecting:\n$EXPECTED_RESPONSE" >&2
      echo "Got:\n$RESPONSE" >&2
      exit 1
    fi
}

# Create data bundle

docker run --rm -v `pwd`/data:/data:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /data > data.json

SHA256=$(sha256sum data.json | awk '{print $1}')

# Upload to staging and reload

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_STAGING
export AWS_REGION=$AWS_REGION_STAGING
export AWS_S3_BUCKET=$AWS_S3_BUCKET_STAGING
export AWS_S3_KEY=$AWS_S3_KEY_STAGING
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_STAGING

export USERNAME=$USERNAME_PRODUCTION
export PASSWORD=$PASSWORD_PRODUCTION

aws s3 cp data.json s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}

curl "https://${USERNAME}:${PASSWORD}@app-interface.staging.devshift.net/reload"

wait_response \
    "https://${USERNAME}:${PASSWORD}@app-interface.staging.devshift.net/sha256" \
    "$SHA256"

# Upload to prodution and reload

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_PRODUCTION
export AWS_REGION=$AWS_REGION_PRODUCTION
export AWS_S3_BUCKET=$AWS_S3_BUCKET_PRODUCTION
export AWS_S3_KEY=$AWS_S3_KEY_PRODUCTION
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_PRODUCTION

export USERNAME=$USERNAME_PRODUCTION
export PASSWORD=$PASSWORD_PRODUCTION

aws s3 cp data.json s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}

curl "https://${USERNAME}:${PASSWORD}@app-interface.devshift.net/reload"

wait_response \
    "https://${USERNAME}:${PASSWORD}@app-interface.devshift.net/sha256" \
    "$SHA256"

exit 0
