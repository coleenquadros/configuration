# Onboarding an App

<!-- TOC -->

- [Onboarding an App](#onboarding-an-app)
    - [Overview](#overview)
    - [Defining the app in App-Interface](#defining-the-app-in-app-interface)
    - [CI/CD Jobs](#cicd-jobs)
    - [Monitoring](#monitoring)
    - [Defining the SLO](#defining-the-slo)
    - [Developer Access](#developer-access)
    - [OpenShift](#openshift)
    - [SOPs](#sops)

<!-- /TOC -->

## Overview

As an application / service onboards with the AppSRE team, it requires all the developer / contributor teams to go through a process. This doc aims to lay out what the checklists are, and what the expectations might be from the developer side at each state, and AppSRE side for each stage.

The onboarding phases are the following:

- **Introduction / Engagement**. In this phase the application development team engages with AppSRE to verify the viability and supportability of the application. The application development team provides documentation around the application, and the AppSRE team analyzes it to certify that it follows the best-practices required to be accepted. After completing this phase the application is determined supportable by the AppSRE team.

- **Onboarding**. During this phase the application development team, with the guidance and help of the AppSRE team, will self-service the deployment of the application via AppSRE's offerings. Most of the work that happens in this phase are PRs submitted by the application development team to onboard the application into App-Interface.

## Introduction / Engagement

The application development team must submit a JIRA issue to the [AppSRE project](https://issues.redhat.com/projects/APPSRE).

This issue must contain or reference a google doc with the following bits of information:

- A high level architecture of the service. Preferably with a diagram.
- Service Owner contact and information about the (active) development team for escalations.
- Upstream repositories.
- Internal and external dependencies. They must be testable and may include other services.
- Specific application requirements / dependencies in the OpenShift cluster: affinity/anti-affinity, namespace co-location with other applications, etc.
- Language stacks, main library dependencies and installation channels.
- Information about the container images: `FROM` fields, and whether the stacks are being upgraded upon container image building.
- Public routes and API endpoints / documentation.
- Detailed and quantified data flow models.
- Additional resources required: s3 buckets, etc.
- Application continuity plan. Back up policies and recovery plan if data is lost or degraded.
- Key SLIs and target SLOs.
- Scalability and load testing of the application.
- Capacity requirements and future growth forecast.
- Service can run on OSD and deployed with dedicated-admin permissions.

AppSRE team will follow-up with the team on the JIRA issue and work through the items in this list until the application can begin its onboarding process.

## Onboarding

Onboarding a new App onto the App-SRE's team contract involves many different steps. These are the requirements for the App to be fully onboarded:

- The app is is properly defined in the [App-Interface](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services)
- Upstream repo contains a build-master script, a pr-check script and the OpenShift manifests.
- CI/CD jobs have been added. See [ci.int](ci-int.md) or [ci.ext](ci-ext.md).
- The software is packaged into containers and hosted in the [quay.io/app-sre](https://quay.io/organization/app-sre) org.
- Monitoring has been set-up.
- SaaS repos exist and the dev teams have merge access.
- An SLO has been defined.
- Developer access to the App is represented properly in roles/permissions in the App-Interface.
- The Escalation matrix is properly defined.
- OpenShift resources: it has a staging environment targetting a staging namespace and a production environment targetting a production namespace.
- There documented SOPs to help triage possible problems with the app running in production.

A WIP step by step guide can be found [here](onboarding-app-step-by-step/).

### Defining the app in App-Interface

A document representing the application must be defined in under the [data](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data) with name `data/services/<service_name>/app.yml`.

The required fields for this document is listed here:
https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/app-sre/app-1.yml

Some of the properties are required, whereas some aren't. However please take into consideration that not defining some of the optional fields will **decrease the SLO** value.

### CI/CD Jobs

Each deployed upstream repo must have 2 CI/CD jobs:

- **build-master**: Creates the container image and uploads to the [quay.io/app-sre](quay.io/organization/app-sre) org.
- **pr-check**: Tests any PR to verify the viability of creating the container image and running tests.

Additionally each component must be associated to a [saasherder](https://github.com/openshiftio/saasherder) repo. We refer to these repos as saas-repos, and they control the CD of the component, both to staging and to production.

More info here: [ci.int](ci-int.md) for upstream repositories in GitLab or [ci.ext](ci-ext.md) for upstream repositories in GitHub.

### Monitoring

Monitoring relies on a Prometheus / Alertmanager stack. Read more about it [here](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/monitoring.md).

### Defining the SLO

The SLO is manually assigned by the App-SRE team.

It depends on things like:

- Completeness of all the values defined in the app document. For example EndPoints, CodeComponents and Escalations.
- The service can support 3 or more replicas.
- The container image is hosted in [quay.io/app-sre](quay.io/organization/app-sre).
- If the OpenShift cluster it's running on is multi-AZ.
- SOPs have been documented.
- The App-SRE team has privileges to create commits in the upstream repos in order to create an emergency release.

### Developer Access

The developer access will rely on the [App-Interface](https://gitlab.cee.redhat.com/service/app-interface) and will be created by the App-SRE team.

### OpenShift

OpenShift resources are defined in `OpenShift Templates` in the upstream repo, and applied via the saasherder process.

Exceptionally, sensitive resources like Secrets, ConfigMaps, Routes,
ServiceMonitors, etc are managed via
[App-Interface](https://gitlab.cee.redhat.com/service/app-interface).

### SOPs

The developer team must create a catalog of SOPs to help the AppSRE team to triage and operate the service.
