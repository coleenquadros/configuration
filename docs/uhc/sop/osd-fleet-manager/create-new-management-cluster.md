<h1>SOP Template</h1>
 
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
 
 
- [1 Introduction](#1-introduction)
  - [1.1 Reference Articles](#11-reference-articles)
  - [1.2 Use Cases](#12-use-cases)
  - [1.3 Success Indicators](#13-success-indicators)
  - [1.4 Stakeholders](#14-stakeholders)
  - [1.5 Additional Details](#15-additional-details)
- [2 Procedure](#2-procedure)
  - [2.1 Plan](#21-plan)
  - [2.2 Prerequisites](#22-prerequisites)
  - [2.3 Execute](#23-execute)
  - [2.4 Validate](#24-validate)
  - [2.5 Issue All Clear](#25-issue-all-clear)
- [3 Troubleshooting](#3-troubleshooting)
- [4 References](#4-references)
 
<!-- END doctoc generated TOC please keep comment here to allow auto update -->
 
# 1 Introduction
 
This document defines the steps to execute for create a new Management Cluster manually

 
## 1.1 Reference Articles
 
https://gitlab.cee.redhat.com/service/osd-fleet-manager/-/blob/main/openapi/fleet-manager.yaml#L415
 
## 1.2 Use Cases
 
A new Management Cluster is needed and the user wants to force its creation

## 1.3 Success Indicators
 
A new Management Cluster is created

## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 

NOTE: There is currently a limitation to the number of management clusters we can create in total in each of integration and stage. Due to using a single AWS Account for each environment, we are limited to 5 total clusters in that environment. This means that if only a single region is enabled, we are limited to 1 SC and 4 MC in that environment. This limitation will be lifted once the AAO integration is in place and each cluster is created within its own AWS Account. 
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have the permissions
* to create (POST) and list (GET) Management Clusters 
* to list (GET) Service Cluster
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
First, determine which service cluster the new management cluster should be added to. Specifically, the ID of the service cluster will be required in the management cluster creation API request body.

Use the service clusters API to list the available service clusters

```
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters --parameter search="status is 'ready'"
```

The output can further be filtered by the required region:

```
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters --parameter search="status is 'ready' and region is ‘us-west-1’"
```

The following request can then be made to create a new management cluster for a given service cluster ID, replacing `${SERVICE_CLUSTER_ID}` below:

```
$ echo ‘{“service_cluster_id”:”${SERVICE_CLUSTER_ID}”}’ | ocm post /api/osd_fleet_mgmt/v1/management_clusters
```

 
## 2.4 Validate
 
The status of the new management cluster can be tracked using the management cluster list APIs:

```
$ ocm get /api/osd_fleet_mgmt/v1/management_clusters 
$ ocm get /api/osd_fleet_mgmt/v1/management_clusters/${ID}
```
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
N/A
 
# 4 References
 
Creation of management cluster through the API is documented in the OpenAPI spec here: https://gitlab.cee.redhat.com/service/osd-fleet-manager/-/blob/main/openapi/fleet-manager.yaml#L415
