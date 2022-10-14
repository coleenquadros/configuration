#! /bin/bash

set -e

: "${CLUSTER:?Please export CLUSTER}"

log() {
    echo "$(date) - $*"
}

log "Working on cluster '${CLUSTER}'"

if ! jq --help > /dev/null ; then
    exit 1
fi

if ! ocm whoami > /dev/null ; then
    echo "Ensure you have ocm installed in your PATH"
    echo "Go to https://console.redhat.com/openshift/token to get a new one and then use the 'ocm login --token=...' command to log in with that new token."
    exit 1
fi

if ! oc whoami > /dev/null ; then
    echo "Ensure you have oc installed in your PATH"
    echo "Please oc login to the openshift cluster '${CLUSTER}'"
    exit 1
fi

CLUSTER_ID=$(ocm get /api/clusters_mgmt/v1/clusters | jq -r ".items[] | select(.name==\"${CLUSTER}\") | .id")
if [ -z "${CLUSTER_ID}" ] ; then
    echo "Could not find OCM cluster id. Are you sure you spelled the clustername correctly: '${CLUSTER}'"
    exit 1
fi
log "${CLUSTER} OCM cluster id: ${CLUSTER_ID}"

CLUSTER_API="/api/clusters_mgmt/v1/clusters/${CLUSTER_ID}"

# OC_USER=$(oc whoami)
# if [[ ${OC_USER} == system* ]] ; then
#     echo "Please oc login with your own user, not with a serviceaccount"
#     exit 1
# fi

OCM_CLUSTER_API_URL="$(ocm get ${CLUSTER_API} | jq -r '.api.url')"
OC_CURRENT_CONTEXT=$(oc config current-context)
OC_CURRENT_CLUSTER=$(oc config view -o jsonpath="{.contexts[?(@.name == \"${OC_CURRENT_CONTEXT}\")].context.cluster}")
OC_CLUSTER_API_URL=$(oc config view -o jsonpath="{.clusters[?(@.name == \"${OC_CURRENT_CLUSTER}\")].cluster.server}")
if [ "${OCM_CLUSTER_API_URL}" != "${OC_CLUSTER_API_URL}" ] ; then
    echo "Please oc login to the cluster '${CLUSTER}' (API URL ${OCM_CLUSTER_API_URL})."
    echo "Your oc CLI is currently logged in to ${OC_CLUSTER_API_URL}"
    exit 1
fi

# if ! ocm get "${CLUSTER_API}/groups/cluster-admins/users/${OC_USER}" > /dev/null 2>&1 ; then
#     log "Adding ${OC_USER} to the cluster-admins group ..."
#     echo "{\"kind\":\"User\",\"id\":\"${OC_USER}\"}" | ocm post "${CLUSTER_API}/groups/cluster-admins/users"
#     log "Awaiting cluster-admins permissions to be effective ..."
#     while ! oc auth can-i delete crd > /dev/null 2>&1 ; do
#         echo -n "."
#         sleep 1
#     done
#     echo ""
# fi
# log "User ${OC_USER} is part of the cluster-admins group"

if ocm get "${CLUSTER_API}/addons/cluster-logging-operator" > /dev/null 2>&1 ; then
    log "Uninstalling the addon ..."
    ocm delete "${CLUSTER_API}/addons/cluster-logging-operator"

    log "Waiting for addon deletion on OCM, ensuring unhandled resources remain deleted. This can take up to 20min ..."
    while ocm get "${CLUSTER_API}/addons/cluster-logging-operator" > /dev/null 2>&1 ; do
        echo -n "."
        oc delete -n openshift-logging clusterserviceversion -l operators.coreos.com/cluster-logging.openshift-logging > /dev/null 2>&1
        sleep 5
    done
    echo ""
    log "Addon uninstalled"
else
    log "Addon not installed. Continuing ..."
fi

log "Ensuring final cleanup ..."
oc delete -n openshift-logging clusterlogging,clusterlogforwarder --all || echo "... This is expected"
oc delete -n openshift-logging clusterserviceversion -l operators.coreos.com/cluster-logging.openshift-logging
oc delete -n openshift-logging --ignore-not-found catalogsource addon-cluster-logging-operator-catalog
oc delete -n openshift-logging --all subscriptions.operators.coreos.com,operatorgroup,installplan,catalogsource
# not removing CRDs. This will get upgraded by the operator deployment.
# oc delete --ignore-not-found crd clusterloggings.logging.openshift.io
# oc delete --ignore-not-found crd clusterlogforwarders.logging.openshift.io 
oc delete --ignore-not-found -n openshift-logging secret addon-cluster-logging-operator-parameters

# log "Removing ${OC_USER} from the cluster-admins group ..."
# ocm delete "${CLUSTER_API}/groups/cluster-admins/users/${OC_USER}"
