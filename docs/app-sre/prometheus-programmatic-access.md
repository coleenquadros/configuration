# Prometheus programmatic access

## Table of contents

* [Introduction](#introduction)
* [For same cluster](#for-same-cluster)
* [For different cluster managed by app-sre](#for-different-cluster-managed-by-app-sre)
* [For service running out of scope of app-sre](#for-service-running-out-of-scope-of-app-sre)


## Introduction

We get requests from our tenant for granting programmatic access to app-sre Prometheus. Since we use openshift-auth-proxy, we can easily allow other service accounts to authorize to Prometheus APIs. [More detail](https://github.com/openshift/oauth-proxy#delegate-authentication-and-authorization-to-openshift-for-infrastructure)

We currently deploy openshift-auth-proxy with [--openshift-delegate-urls](https://gitlab.cee.redhat.com/service/app-sre-observability/-/blob/master/openshift/nginx-proxy.template.yaml#L96) and [ClusterRole](https://gitlab.cee.redhat.com/service/app-sre-observability/-/blob/master/openshift/nginx-proxy.template.yaml#L229-241). Any service accounts which bind with `prometheus-app-sre-access` will have the access to Prometheus and Alertmanager API.

## For the same cluster

If the service only need to query its own cluster's Prometheus, The tenant can query `http://prometheus-app-sre.openshift-customer-monitoring.svc.cluster.local:9090` directly without auth

## For a different cluster managed by app-sre

The tenant can self-service by creating MR in app-interface.

* You need to create an MR to create a service account for the target cluster. [MR-1](https://gitlab.cee.redhat.com/service/app-interface/-/blob/5b8732a58a941cd0f201b2ac7c0e46292a3eb296/data/services/observability/cicd/saas/saas-prometheus-access.yaml#L33-37)
* After the first MR gets merged and applied, you need to create an MR to deliver the service account token to the destination namespace. [MR-2](https://gitlab.cee.redhat.com/service/app-interface/-/blob/c84d0f59831c4a2f44044098431d2c098639f18b/data/services/ocm/namespaces/uhc-integration.yml#L157-161)
* You will find a secret called: `<targetClusterName>-app-sre-observability-per-cluster-<ServiceAccountName>`. The Secret will have a single key called token, containing a token of that ServiceAccount.[More detail](https://gitlab.cee.redhat.com/service/app-interface#self-service-openshift-serviceaccount-tokens-via-app-interface-openshiftnamespace-1yml). 
* You can query the target cluster Prometheus API via using sa token as the bearer token.


## For service not running on AppSRE clusters

Tenant will need to create a ticket for [App-SRE](https://issues.redhat.com/projects/ASIC/issues)

* You need to create an MR to create a service account for the target cluster. [MR-1](https://gitlab.cee.redhat.com/service/app-interface/-/blob/5b8732a58a941cd0f201b2ac7c0e46292a3eb296/data/services/observability/cicd/saas/saas-prometheus-access.yaml#L33-37)
* You need to ping @app-sre-ic to get the service account token and paste it in [vault](https://vault.devshift.net/) 
