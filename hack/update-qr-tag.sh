#!/bin/sh

# standalone qontract-reconcile tag auto-updater
# if DO_COMMIT env var is set to any value, this will automatically commit

# set GHTOKEN to github token or place in $GHTOKEN_FILE
GHTOKEN_FILE="${HOME}/.ssh/.github-token"
# github org/repo
QREPO="app-sre/qontract-reconcile"
# curl connect timeout
TIMEOUT="5"

# location of files needing update
ENV_FILE=".env"
SAAS_FILE="data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml" 
JENK_FILE="resources/jenkins/global/defaults.yaml"

# Required dependencies
REQUIRES="curl"

function check_depends {
  for cmd in ${REQUIRES}; do
    cmdloc=$(which ${cmd})
    if [ ${?} -ne 0 ]; then
      echo "Error, ${cmd} not found in path. Please install."
      exit 1
    fi
  done
}

function curl_status {
  # check return code from curl
  if [ ${1} -ne 0 ]; then
    echo "Curl error"
    exit ${1} 
  fi
}

function hash_status {
  # Hasheseses info
  echo "Current Hash (${HASH_SHORT}) [${HASH}]"
  if [ -z "${HASH}" ] || [ -z "${HASH_SHORT}" ]; then
    echo "Holdupaminute.. something is wrong with the current hash value"
    git status
    exit 1
  fi
  echo ""
  echo "${COMMIT_MESSAGE}" | awk '{print "    "$0}'
  echo ""
  if [ "${HASH}" == "${NEWHASH}" ] || [ "${HASH_SHORT}" == "${NEWHASH_SHORT}" ]; then
    echo "Holdupaminute.. hash already applied?"
    git status
    exit 1
  fi
  echo "New Hash (${NEWHASH_SHORT}) [${NEWHASH}]"
  echo ""
  echo "${NEWCOMMIT_MESSAGE}" | awk '{print "    "$0}'
  echo ""
  echo "---"
}

function update_files {
  echo "Updating envfile (${ENV_FILE})"
  # export RECONCILE_IMAGE_TAG=nnn
  sed -i -c -E 's/^(export RECONCILE_IMAGE_TAG=).*$/\1'${NEWHASH_SHORT}'/g' ${ENV_FILE}
  echo "Updating saasfile (${SAAS_FILE})"
  # ref: nnn
  sed -i -c -e 's/'${HASH}'/'${NEWHASH}'/g' ${SAAS_FILE}
  echo "Updating jenkinsfile (${JENK_FILE})"
  # qontract_reconcile_image_tag: 'nnn'
  sed -i -c -e 's/'${HASH_SHORT}'/'${NEWHASH_SHORT}'/g' ${JENK_FILE}
}
  

if [ -z "${GHTOKEN}" ] && [ -e "${GHTOKEN_FILE}" ]; then
  GHTOKEN=$(cat ${GHTOKEN_FILE})
fi

if [ ! -z "${GHTOKEN}" ]; then
  GHAUTH="-H \"Authorization: token ${GHTOKEN}\""
else
  echo "No GHTOKEN set or FILE (${GHTOKEN_FILE}) not found"
  echo "Using anonymous github account (may fail due to rate limits)"
  GHAUTH=""
fi

CURLCMD="curl -s --connect-timeout ${TIMEOUT}"

if [ -z "${NEWHASH}" ]; then
  echo "Tag not provided, gathering latest commit"
  NEWHASH=$(${CURLCMD} ${GHAUTH} "https://api.github.com/repos/${QREPO}/commits?sha=master&per_page=1" | jq -r '.[0].sha')
  curl_status ${?}
fi
NEWCOMMIT_MESSAGE=$(${CURLCMD} ${GHAUTH} "https://api.github.com/repos/${QREPO}/commits/${NEWHASH}" | jq -r '.commit.message')
curl_status ${?}
NEWHASH_SHORT="${NEWHASH:0:7}"

HASH_SHORT=$(awk -F\= '($0~/^export RECONCILE_IMAGE_TAG=/) {print $NF}' ${ENV_FILE})
HASH=$(awk -F\: '($0~/ref: '${HASH_SHORT}'/) { gsub(/ /,"",$NF); print $NF}' ${SAAS_FILE})
COMMIT_MESSAGE=$(${CURLCMD} ${GHAUTH} "https://api.github.com/repos/${QREPO}/commits/${HASH}" | jq -r '.commit.message')
curl_status ${?}

check_depends
hash_status
update_files
echo ""
git diff
echo ""
if [ ! -z "${DO_COMMIT}" ]; then
  git commit -a -m "qontract production promotion ${HASH_SHORT} to ${NEWHASH_SHORT}"
else
  echo "If you're satsified, git commit and enjoy!"
  echo "  git commit -a -m \"qontract production promotion ${HASH_SHORT} to ${NEWHASH_SHORT}\""
fi
