# OSIO set capacity-exhausted flag

## Background

When an OSIO cluster is under heavy load - determined by an App-SRE after receiving monitoring alerts - it is desirable to prevent additional pressure from users by limiting their actions such as creating new workspaces, launching pods, etc...

To do this, the OSIO team has created a new config flag called `capacity-exhausted` which when set to `true` will tell the OSIO services they should limit user activity.

## Purpose

This document describes the process to set the `capacity-exhausted` flag to limit user actions on OSIO"

## Requirements

The App-SRE member need to have access to:
- merge changes in App-Interface
- Vault (update secret)
- Prometheus/Grafana (for informational purposes)

# Setting the `capacity-exhausted` flag permanently

## Pre-check list
1. Determine which cluster is at full capacity
   - What resource is under stress? (CPU/Memory)
   - Has the cluster been under stress for some time?
   - Grafana can be used to answer the questions: https://grafana.app-sre.devshift.net/d/osio_capacity/osio-capacity
2. Use judgement to determine if this is a temporary spike or fairly constant high resource consumption (to avoid playing whack-a-mole)

## Set the `capacity-exhausted` flag
1. Login to Vault
2. Locate secret `app-interface/dsaas/dsaas-production/f8cluster-config-files`
3. Click `Create new version`
4. Locate the cluster for which you want to set the flag
5. Add or update a key called `capacity-exhausted` and set it to `true` (boolean, not string, so NO DOUBLE-QUOTES)
6. Save the secret and make note of the new secret version
7. Go to app-interface and locate `data/services/openshift.io/namespaces/dsaas-production.yml`
8. Find the secret for `f8cluster-config-files` and bump the version
9. Submit the MR, wait for the checks to pass, validate the app-interface output, merge.
10. Within a few minutes the new secret should be applied and the flag will be set

**There is no need to restart services as the `f8cluster` will pick-up the changes automatically and reconfigure itself**

An example of the config file can be seen upstream: https://github.com/fabric8-services/fabric8-cluster/blob/master/configuration/conf-files/oso-clusters.conf
