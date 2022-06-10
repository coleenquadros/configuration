# Initiative Document - Fine grained app-interface review permission model

## Author / Date

Gerd Oberlechner / June 2022

## Context

`app-interface` is a gitops configuration management system used by AppSRE tenants to declaratively define services and all their dependencies. AppSRE is responsible for the management of those services and therefore reviews changes to service declarations carefully, to make sure

* changes don’t break production
* changes adhere to the [AppSRE contract](https://gitlab.cee.redhat.com/app-sre/contract/-/tree/master)

## Problem Statement

The change rate in `app-interface` has increased significantly and IC has become a stressful role with multiple interrupt channels to deal with concurrently. At the same time, there are change types that are repetitive and get reviewed following a common pattern, e.g. add a new role member. Certain change types are not considered critical in stage environments but require the same IC review than in production, e.g. RDS minor version updates or promoting vault secrets. Too many change types in `app-interface` turn IC work into toil with diminished value added by the review process.

Additionally, Service Delivery partner SRE teams want to self service entire services on their own, e.g. CSSRE wants to manage the RHOSAK control plane without the need for AppSRE reviews.

## Goal

Reduce the number of changes to be reviewed by AppSRE.

## Prior Art

With saas file self-service, a feature is available to tenant teams to review their own changes on certain fields of their saas files. This has has reduced AppSRE IC review work a lot.

## Proposal

With this initative we are going to extend the idea of saas file self-service to delegate review work on a broader scale.

We will define configuration schemas to describe change types in `app-interface` and combine them with `app-interface` data ownership to allow teams to review explicitely defined changes on their own. This will result in a fine grained permission model that

* decreases AppSRE IC review load
* enables Service Delivery partner SRE teams to fully own dedicated services

## Milestones

### Milestone 1 - Change detection in qontract-server bundles

In this milestone, we will create a design to detect changes in MRs. The conducted feasibility spike will be the basis of the design, proposing change detection by using a `qontract-server` with two bundles loaded - one representing the current state of the `app-interface` HEAD of master branch and the other one the desired state introduced by the MR. This will enable powerful diff calculation and running queries towards both states.

This milestone will also move the PR check code from `app-interface` to `qontract-reconcile` to dedup the need for maintaining it in `app-interface` commercial and fedramp. The PR check code will have access to the dual-bundle `qontract-server` to find out about involved schemas and valid saas file changes. This will also eliminate the need to communicate with the production `qontract-server` during PR checks as we do it today to prevent privilege escalation.

### Milestone 2 - Define change types and review permissions as qontract-schema objects

Being able to declare what changes can be reviewed by tenants is the cornerstone of this initiative. In this milestone, we will define how change types and review permissions can be stored as `qontract-schema` objects in an `app-interface` instance.

This milestone includes spiking and implementing `qontract-schema` and `qontract-reconcile` changes to resolve a PR to the people who can review it. This milestone is not yet about allowing those people to actually review. Instead we will have a couple of change type and review permission definitions evaluated during PR checks and reporting their results to us. This will allow us to observe and gain insights about the future behaviour of the permission system.

### Milestone 3 - Define MR approval flow

While milestone 2 was about identifying the reviewers of a change, this milestone defines the process of actually allowing them to approve an MR. This includes the interaction of the appsre gitlab bot with the MR as well as the reviewers interaction with the MR.

This milestone will bring immediate value, allowing us to delegate reviews to tenants for the change types we defined in milestone 2.

### Milestone 4 - Establish process to create new change types and grant permissions

In this milestone we will establish a process how relevant change types suitable for self-service review can be identified and accepted by the AppSRE team.
Additionally we will set up guidelines, how review permissions will be granted to tenants.

These processes will allow us to scale the fine grained permission model, continously reducing review toil.
