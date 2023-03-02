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
 
This document defines step to follow to disable a region.
Disabling a region is analog to deleting the last Service Cluster running on this region and making sure no new Service Cluster is schedule for this region.
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
A region is no longer to be supported by Fleet Manager 
## 1.3 Success Indicators
 
At the end of the procedure, not clusters shall be listed in Fleet Manager for the disabled region
 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
N/A 
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have access and have mergre permission to [app-interface](https://gitlab.cee.redhat.com/service/app-interface)
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
The regions that are enabled are defined in the app-interface SAAS file for OSD Fleet Manager, separately for each environment in int/stg/prod: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm/osd-fleet-manager/cicd/deploy.yaml

An MR is required to app-interface to remove the entry from the enabled_regions list in that file. Once the file is merged, the change will be propagated to the pods via normal deployment flows.

Verify that the region has been disabled with: `$ rosa list regions`

Once disabled, the management and service clusters will not be automatically deleted. They must each be deleted manually via the API:

List existing clusters in the region
```
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters?search="region like '$REGION"
$ ocm get /api/osd_fleet_mgmt/v1/management_clusters?search="region like '$REGION"
``` 
And then
```
$ ocm delete /api/osd_fleet_mgmt/v1/management_clusters/${ID}
$ ocm delete /api/osd_fleet_mgmt/v1/service_clusters/${ID}
```
 
## 2.4 Validate
 
```
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters?search="region like '$REGION"
$ ocm get /api/osd_fleet_mgmt/v1/management_clusters?search="region like '$REGION"
``` 
Should return empty items.
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
N/A 
# 4 References
 
N/A
