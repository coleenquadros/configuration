# Design doc: Qontract Operator (Integrations Manager)

## Author/date

Maor Friedman / 2022-05-02

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-2963

## Problem Statement

To deploy services, we expect an OpenShift template in the code repository.

Qontract-reconcile integrations have a [generated OpenShift template](https://github.com/app-sre/qontract-reconcile/tree/master/openshift) (using a [Helm chart](https://github.com/app-sre/qontract-reconcile/tree/master/helm) in the repository). This is because an integration can run for different app-interface instances (commercial vs. fedramp for example), or even for the same app-interface instance, but in different environments (external vs. internal for example).

With this approach, adding an existing integration to a new environment requires a PR to the qontract-reconcile repository to update a (Helm) values file with the `spec` of the integration (resources, slack logs, state, etc). This also means that adding a new environment requires a new values file in qontract-reconcile.

Since integrations are already defined in app-interface instances (usually under `/data/integrations`), this creates a duplication.

So the problem statement may be - adding an integration to an app-interface instance is too complicated.

## Goals

Simplify the process of adding ("installing") an (existing) integration to other app-interface environments/instances.

## Non-objectives

* Adding a new integration may imply developing a new integration. This is not the problem we are solving. We want to simplify adding an integration, rather than developing one.

## Proposal

To run an integration against an app-interface instance, an integration file must exist for that integration, otherwise the integration execution will fail.

This means that the information about what integrations should be enabled in an app-interface instance already exists in the form of integration files. This means the information is queryable, which means we can write an integration to act on that information.

The proposal is to create a new integration to manage (operate) other integrations: `integrations-manager`.

This integrations manager continuously polls app-interface. In case a new integration file was added, the integrations manager will deploy the required integration.

Generally speaking, the integrations manager is "just" an integration that manages OpenShift resources, such as `Deployment`, `CronJob` and `StatefulSet`. It collects data from an app-interface instance, constructs OpenShift resources based on that data and applies it to a namespace (or namespaces).

The integrations manager will need to be able to do 2 things:
1. Deploy integrations to different environments with different settings ("spec").
2. Construct OpenShift resources that match the way we currently do (that is the Helm chart).

Schema time!

We will extend the `integration-1` schema to add a new field - `operate`. This field will hold information on where to run the integration (environment) and what spec to run it with:
  ```yaml
  $schema: /app-sre/integration-1.yml

  name: aws-ami-share

  description: Share AMI and AMI tags between accounts

  upstream: https://github.com/app-sre/qontract-reconcile

  operate:
  - namespace:
      $ref: /path/to/namespace/file.yml
    spec:
      resources:
        requests:
        limits:
      logs:
        slack: true
      shards: 1
      ... # additional settings as available in the Helm chart templating
  ```

The `namespace` section will reference a namespace where the integrations manager runs. This will be the integrations manager's way of knowing where to deploy additional integrations to (right next to itself). To be able to only manage the same environment it is running it, the integrations operaotor will have environment awareness information (in the form of environment variables) of: what environment am I serving. When the environment variable exist, the integration will only manage the given environment. When it is not defined, the integration will manage all environments. The latter is intended for use in app-interface pr-check.

We will use the namespace as a reference, which in turn references an environment. We will use the environment to provide a way for the integrations manager to get a hold of additional environment parameters that should be used to deploy the integrations.

The spec section will hold information on how to run each integration. It will be identical to the existing sections in each environment's values file.

At this point, integrations manager knows what integrations to deploy, where to deploy them, and what they should look like.

> Note: This PR was submitted for further illustration: https://github.com/app-sre/qontract-schemas/pull/137

Construction time!

The hardest part of this problem is how to construct OpenShift resources that represent the different integrations. From the qontract-reconcile Helm chart, we learn that every integration has a spec of how it needs to run. We currently use the same spec to generate the OpenShift template which is then committed to the qontract-reconcile repository.

The integrations manager will create a values file on its own, and will use the existing Helm chart to construct the OpenShift template.

Since the integrations manager is an integration, we will still use the Helm chart to generate the OpenShift template to deploy the integrations manager itself. This means that every alternate location or method to store OpenShift templates becomes a duplication.

In addition, wrapping an manager around a Helm chart is not something we invented: https://sdk.operatorframework.io/docs/building-operators/helm/

Using the Helm chart is also backwards compatible. It means that integrations can either be operated by integrations manager, or deployed as they were until now. This will allow a very smooth migration for integrations from being "deployed", to being "operated".

## Alternatives considered

Alternatives were considered for two areas:

* Should this be an integration or a new command, like qontract-cli?
Starting out with an integration saves a lot of overhead (new python command, generalizing the Helm chart to allow deployment, etc). Since we are not limited from moving the integration out of the `qontract-reconcile` cli in the future, we went for simplicity.

* How should we construct the OpenShift resources?
This was quite the struggle. We chose to go with using the same generation mechanism, the Helm chart. Other possibilities were:
  - Create static files in the qontract-reconcile repository, a file per possible spec combination (with state, without slack | with slack, without state, with shards, ...). This approach would not scale, as any additional spec option will mean 2x static files.
  - Create a file within app-interface and reference it (like we do in openshift-tekton-resources). This will introduce a new way to deploy integrations, while we still need the Helm chart to maintain backwards compatibility and to support an on going migration. We will probably also need to use additional templating, such as jinja2, which will further complicate things.

## Milestones

Milestone 1: Develop integrations-manager.
Milestone 2: Deploy a single integration via the manager (email-sender?)
Milestone 3: Deploy all integrations via the manager
Milestone 4: Enable dynamic number of shards (based on app-interface data). For example, openshift-resources should run with N shards, N being number of clusters managed in app-interface.
