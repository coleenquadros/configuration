# OSIO starter clusters capacity and subscribers limits

## Definitions

`capacity` - The number of users that can be subscribed to an OpenShift Online cluster (osio or not)

`limit` - The subscribers limit as enforced by the [OpenShift Online Registration portal](https://manage.openshift.com/admin/)

`hidden` - A hidden cluster means it will be excluded from clusters available for provisioning users

## Background

OSIO users registers for the service via the standard OpenShift Online flow. This registration flow is handled by the [OpenShift Online Registration portal](https://manage.openshift.com/admin/), which include an admin portal. Upon registering, the user is placed in a queue and assigned a cluster that corresponds to the registrations criterias. For OSIO, only clusters of type `OpenShift.io` are considered. The registration app will select a cluster based on the following:
- Enough capacity is available
- Cluster is not hidden
- First cluster where capacity is available as returned by the DB (NOT round-robin, NOT random)

## Purpose

This document aims to describe processes that has to be done manually from time to time in order to control where OSIO users are provisioned.

## Requirements

The App-SRE member need to have access to the [OpenShift Online Registration portal](https://manage.openshift.com/admin/) and need to have enough privileges to be able to access the admin section.

# Adjusting cluster capacity

A dashboard is available here  [Prometheus](https://grafana.app-sre.devshift.net/d/osio_capacity/osio-capacity?orgId=1&from=now-1h&to=now)

To adjust cluster capacity limits, a user must:
- Login to the [OpenShift Online Registration portal](https://manage.openshift.com/admin/)
- Click the `Admin Panel` button on the top right of the page
- Go to `Plans`
- Search for `Display Name` = `OpenShift.io`
- Edit the clusters as needed
    - Raise or lower the limit so that there is less or more capacity available
    - Hide or unhide the clusters
**Note: don't unhide -1a and -1b clusters, they are currently in DRAIN mode and scheduled for tearing down in Sept 2020.**

*Note:* The registration portal does not support provisioning users to clusters that are available and with enough capacity in a random or round-robin maner.

![registration app](images/regapp1.png)
