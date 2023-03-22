#!/bin/bash

# Locally test dual bundle functionality of Qontract Server
# Run using `make dual-bundle-run`
# This requires you to be on a branch separate from master and preloads
# QS with the branch from your bundle as well as the master branch for testing
# integrations which require dual bundle functionality

TEMP_DIR=${TEMP_DIR:-./temp}
WORK_DIR=$(realpath -s "$TEMP_DIR")
MASTER_BUNDLE_FILE="${PWD}"/data.json

if [ -z "$1" ]; then
    echo "usage: dual-bundle-qs.sh CONTAINER_ENGINE"
    exit 1
fi

rm -rf "${WORK_DIR}"
mkdir "${WORK_DIR}"
source ./.env

# checkout master worktree
MASTER_WORKTREE_DIR="./master"
git worktree add ${MASTER_WORKTREE_DIR} master

# generate master bundle
pushd ${MASTER_WORKTREE_DIR} || exit
mkdir -p validate
make schemas bundle validate
popd || exit

# copy both master.json and data.json to the temp dir
cp ${MASTER_WORKTREE_DIR}/data.json "${WORK_DIR}"/master.json
cp "${MASTER_BUNDLE_FILE}" "${WORK_DIR}"/data.json

git worktree remove master

INIT_BUNDLES="fs:///bundle/master.json,fs:///bundle/data.json"

# run qontract-server in dual bundle mode
$1 run -it --rm \
    -p 4000:4000 \
    -e LOAD_METHOD=fs \
    -e DATAFILES_FILE=/bundle/data.json \
    -e INIT_BUNDLES=${INIT_BUNDLES} \
    -v "${WORK_DIR}":/bundle:z \
    "${QONTRACT_SERVER_IMAGE}":"${QONTRACT_SERVER_IMAGE_TAG}"

rm -rf "${WORK_DIR}"
