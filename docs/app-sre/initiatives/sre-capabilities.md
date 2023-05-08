# Initiative Document - SRE capabilities

## Author / Date

Gerd Oberlechner / April 2023

## Context

AppSRE has build up an extensive knowhow and experience in SREing well known Red Hat managed services. This experience has been codified in tools like qontract-reconcile in the form of integrations, which solve an automation aspect for service management like creating cloud assets, managing secrets, configuring alerting, defining CD/CD etc.

AppSREs tooling is accessible in a self-service manner to all tenants that onboard their services with AppSRE following the ROMS process. But at the same time, features like Advanced Cluster Upgrades Service would generate value beyond that audience.

From a desire to bring the expertise and knowhow to a broader audience, the idea of `SRE capabilities` was born. An SRE capability is a building block to run a service in a reliable and sustainable way. Combining those capabilities enables engineering teams to run a service professionally and wholesome with low toil.

## Problem Statement

With SRE capabilities we are opening up new pathways for AppSRE tooling to be used by all Red Hat engineering teams. The current tenant interaction model, support model etc. are not build for that.

In app-interface, the service acts as a centerpiece that gives context to all the infrastructure and process information that is woven around it. With SRE capabilitiets, where single automation aspects of app-interface might be used a-la-card and a full onboarding is not desireable, this centerpiece is missing. Placing configuration data into app-interface without the context of the service is undesireable because it blures the relationship to tenants/users, bloats the repository beyond its purpose and leaves AppSRE with an unclear support model.

Even if certain AppSRE integrations and SRE capabilities will provide the same service, they will do it differently and will require specific processes, environments and boundary conditions while doing so.

## Goals

- define the consumption model and feedback model for capabilities that does not revolve around app-interface touchpoints
- define a dedicated support model for capabilities that does not revolve around the AppSRE tenant relationship and the contact
- provide a dedicated runtime envirionment and alerting model for capabilities that is aligned with the support model
- but most importantly: start where we are with what we have, a-la-card for a small set of capabilities

## Milestones

### Milestone 0 - offering capabilities as-is

Offer the `Advanced Upgrade Service` capability as is. The [enablement document](https://service.pages.redhat.com/dev-guidelines/docs/sre-capabilities/advanced-upgrade-service/) defines how the consumption model and support model work for now.

Optionally also offer the Red Hat Idp and Cluster access based on rover groups capabilities.

### Milestone 1 - capabilities framework

This milestone is all about shaping the general structure of capabilities, the interaction layer but also reusable patterns for offering existing integrations as capabilities:

- define consumption models for capabilities - how are users going to interact with various kinds of capabilities?
- define feedback models for capabilities - how are users getting feedback about their interaction with a capability, how can they get support?
- define implementation patterns for capabilities -  how to reuse AppSRE integrations as capabilitiets without app-interface backing?

### Milestone 2 - alerting scheme for integrations/capabilities

This milestone is all about defining how AppSRE is sreing capabilities. The current high level observability and alerting strategy for app-interface integrations is not flexible enough for capabilities. This is mostly due to the fact that capabilities will inherently act in environments that are not under full control of AppSRE. This problem can be observed already in app-interface with BYO infrastructure. Therefore, the efforts of this milestone must adress these issues not only for capabilities but also for regular integrations:

- fine grained alerting for integrations/capabilities
- fine grained error budgets and alerting for data partiions (a.k.a. shards)
- define what failing means

### Milestone 3 - capabilities runtime

While milestone 1 was the starting point for offering capabilities with as little changes as possible, this milestone is about reworking the runtime aspects for capabilities, differentiating them from regular AppSRE integrations. This ranges over various aspects like dedicated namespaces, dedicated configuration sources, dedicated cloud assets and dedicated workload management.

This does not imply that the runtime environment for capabilitie will be completely different from the app-interface one. Several aspects like integrations-manager and configuration data via GQL work quite well and enables us to reuse code across integrations and capabilities.
