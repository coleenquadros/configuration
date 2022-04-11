# Design doc: ROSA support in App-Interface

## Author/date

Jordi Piriz / 2022-04-18

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4268

## Problem Statement

As part of hypershift support, we need to be able to manage ROSA type openshift (ROSA) clusters through app-interface. ROSA deployment model uses the customer account to provision all the openshift components (both control plane and data plane). The provisioning is based in the `ROSA cli` tool and `OCM`.

`ROSA cli` basically does require 2 steps to provision a cluster.

- Configure the target AWS account: In this step, the cli configures the AWS account to enable RedHat access to provision and manage the cluster. It creates IAM roles for the openshift cluster components and for the RedHat operators to be able to diagnose things. There are other things like verify quotas and Service control policies (SCP).

- Start the cluster provisioning through `OCM`: `ROSA cli` allows to define the cluster spec with a command line parameters and then it does a request to `OCM` to start the cluster provisioning. All the process is orchestraded from `OCM` using the roles defined in the previous step.

Right now, our `OCM` library and integrations are not compatible with ROSA clusters, they even break when a ROSA cluster exists in our `OCM` organization[1] because the code is strongly tied to `OSD` type clusters.

This design doc is meant to define the implementation details on how we want to proceed to enable app-interface support for `ROSA` clusters.

## Goals

- Identify the changes required by A-I and Q-R to support ROSA
- Define the implementation details on how to provision ROSA clusters.

## Non-Goals

- TBD

## Proposals

### AWS account Pre-requisites

TBD

### AWS account IAM Cluster Roles

TBD

### STS or Not-STS

TBD

## Alternatives considered

Move schemas to their code repositories.

This currently includes only qontract-reconcile and vault-manager, but may include additional repositories with app-interface related automations that may be created in the future.

This approach will be difficult to implement. With only 2 repositories at this time, it is already hard to imagine how to write the bundling process, and most importantly - how to adjust the development process.

It is true that keeping the schemas together with the code is the recommended way. We even recommend that to our tenants. The difference is that in our tenants' case there is a single code repository that works according to the schemas, and in our case there are N.

## Milestones

This work has to happen in a single iteration, as it is a "breaking change".
