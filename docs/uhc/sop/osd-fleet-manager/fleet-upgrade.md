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
 
This document explains how fleet upgrade is managed
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
Fleet upgrade needed

## 1.3 Success Indicators
 
N/A 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
N/A 
 
# 2 Procedure
 
## 2.1 Plan
 
N/A
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
Upgrades are handled automatically through app-interface. The upgrade schedules, soak days, etc can all be modified in the OSD Fleet Manager OCM files in app-interface: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ocm/osd-fleet-manager/stage.yml#L18 Note that if a merge request is created that updates these files, it can typically be merged by another member of the OSD FM team without app-sre involvement.

The solution in app-interface will automatically search for clusters with specific external configuration labels applied through OSD Fleet Manager workers to service and management clusters. It will handle initiating upgrades for these clusters the same way it does for many OSD cluster app-interface manages.

App-SRE maintains the following documentation on the cluster upgrade automation: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/cluster-upgrades.md#cluster-upgrades
 
## 2.4 Validate
 
N/A
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
N/A 
# 4 References
 
N/A
