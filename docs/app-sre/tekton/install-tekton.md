# How to install Tekton on a cluster

## Background

As part of an ongoing effort to derisk ci-int, we are migrating workloads to an internal OSD cluster (connected to the RedHat VPN). This SOP explains how to install Tekton operator on a cluster.

## Process

Submit a MR to app-interface to add the `openshift-operators` namespace file:
```yaml
---
$schema: /openshift/namespace-1.yml

labels: {}

name: openshift-operators
description: <cluster_name> openshift-operators namespace

cluster:
$ref: /openshift/<cluster_name>/cluster.yml

app:
$ref: /services/app-sre/app.yml

environment:
$ref: /products/app-sre/environments/<environment>.yml

managedResourceTypes:
- Subscription

openshiftResources:
- provider: resource
  path: /tekton/openshift-pipelines-operator-rh.subscription.yaml
```
