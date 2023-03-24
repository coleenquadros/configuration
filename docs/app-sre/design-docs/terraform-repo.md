# terraform-repo design doc

[[_TOC_]]

## Introduction

SREP and Insights have come to AppSRE with a need to run terraform projects in an automated fashion outside of the constraints of the terraformResources integration. From the Insights side, we need to support infrastructure that is unique to FedRAMP for their service offering. For SREP, we need to support GoAlert in FedRAMP, our replacement solution for PagerDuty and DMS.

In addition, there are AppSRE use cases for terraform execution of target git repositories. Success of this offering could provide an example on the technology and approach used to manage terraform at the SRE org level.

In terms of existing projects that could have taken advantage of this idea, rosa-authenticator and cloudflare terraform projects would have greatly reduced time to implementation given a solution that existed outside of terraformResources.

**The idea is simple**: create a terraform executor integration which will run terraform operations on a target repository that meets requirements.

## High Level FAQ

### How does this fit with org goals?

* Assists in the pursuit of a big rock - ROSA FedRAMP
* Supports Hybrid SRE and "Everyone owns the SLO" concepts
  * Tenants become responsible for the creation + maintenance of infrastructure
  * AppSRE becomes responsible for the tooling, interactions between tools, and also a consulting role
* This effort contains building blocks that can be used in the development of capabilities
* Incremental changes in small test beds over large all-encompassing projects. Gain followers and trust and then expand

### What are the reusable / portable pieces?

* HCL
* Jenkins / Tekton webhook infrastructure
* GitOps
* Vault secret interface
* Tenant <> SRE expectations, responsibility relationships

### What are the advantages to HCL?

* HCL is portable between execution contexts, projects, and interfaces
* HCL is widely understood by engineering peers
* HCL is supported by terraform code-quality features, like terraform format and terraform validate
* HCL used in terraform-repo projects can be re-used as terraform modules or other future implementations

### Is app-interface required for the concepts to be useful?

* App-interface is not strictly required, although removal or alteration of this pattern would require additional development time.
* There are a multitude of ways to approach the orchestration layer.
* The immediate goal is to solve a problem for our FedRAMP tenants. We can solve the immediate goal and create pieces that are re-usable as the approach to terraform evolves at the org level.

### How does GitOps add value in compliance driven environments?

* GitOps addresses many compliance controls around the development, promotions, and updates to infrastructure
  * two-hand review
  * continuous integration
  * secret management
  * git history as an audit log
  * GitLab interface to compliance surfaces (see (change-control-automation)[change-control-automation.md] design doc for a concrete example)

### What does it mean if we do not proceed with this (or a similar) solution?

We need a solution to manage bespoke infrastructure with terraform in FedRAMP.

Without terraform-repo or an alternative solution, long lived infrastructure that supports tenants and the FR platform must be:

* coded into qontract-reconcile
  * qontract-reconcile providers do not have any of the portability benefits that HCL provides
  * There is a knowledge gap between SREs and AppSRE when it comes to maintaining and updating qontract-reconcile providers
  * Continuous reconciliation does not provide benefit for foundational infrastructure, so onboarding cost to move providers to qontract-reconcile is without clear benefit
  * AppSRE will spend cycles transcribing existing terraform code, spending time on toil and wasting an opportunity for productivity improvement

* or must be run manually on endpoint systems
  * Manual terraform runs of infrastructure mean little to no compliance audit trail
  * Differing policies around merge / apply events for execution of `terraform apply` on a per-repository per-team basis
  * Loss of centralized secret management - with terraform-repo, there is little reason for engineers to store account credentials on their machines to perform stage and production terraform runs

With either option, we lose an opportunity to standardize on a terraform project git repository layout and requirements. A standardized approach to a terraform repository means easier code re-use and migrations to future offerings. 

## Language Definitions

### What is a [module?](https://developer.hashicorp.com/terraform/language/modules/develop)

_From Hashicorp documentation_: "A module is a container for multiple resources that are used together. You can use modules to create lightweight abstractions, so that you can describe your infrastructure in terms of its architecture, rather than directly in terms of physical objects."

"A good module should raise the level of abstraction by describing a new concept in your architecture that is constructed from resource types offered by providers."

"We do not recommend writing modules that are just thin wrappers around single other resource types. If you have trouble finding a name for your module that isn't the same as the main resource type inside it, that may be a sign that your module is not creating any new abstraction and so the module is adding unnecessary complexity." 

### What is a [project / root module?](https://developer.hashicorp.com/terraform/language/files)

_From Hashicorp documentation_: "In Terraform CLI, the root module is the working directory where Terraform is invoked."

To avoid overloading the word module, I will refer to "root modules" as "projects" for this design doc. A __project__ is the working directory where we run terraform commands.

### How do terraform language conventions map to qontract-reconcile conventions?

A qontract-reconcile "provider" is functionally equivalent to a terraform module. A collection of provider instantiations that target a single asset account represents a "project".

## What

Create a new qontract-reconcile integration that provides the ability to run terraform operations (plan, apply) on a target git repository.

app-interface's role in the offering is as follows:

* Associate an AWS account with a terraform repository 
* Control the lifecycle of the terraform repository's executed code through SHA references / GitOps
* Support bootstrapping `terraform-repo` support on a per-asset-account basis with bucket creation and other setup tasks
* Provide the executor with credentials and environment variables needed to complete terraform plan and apply

Using app-interface as the coordination point between a target AWS account and the terraform project that should run in said account makes sense. App-interface has knowledge of AWS accounts and their credentials, can be used to generate state buckets through qontract-reconcile, and can use event-based or reconciliation based strategies to apply new targets or updates to existing targets. Therefore, this design doc relies on app-interface as the coordination point and interface, while execution will reside in CD infrastructure, either Jenkins or Tekton.

Plan and apply both depend on accessing a shared state. The shared state credentials will be available to the integration and to the executor context through pre-existing connections between Vault, OpenShift, and app-interface / qontract-reconcile. Strategies to integrate the plan and apply steps into a workflow are discussed in detail in the “How” section below.

The integration will take advantage of the “externalResources” stanza in a namespace file in app-interface. A user will specify `provider: terraform-repo` in order to enable the integration for a repository that is modeled in app-interface codeComponents.

```yaml
externalResources:
- provisioner:
    $ref: /aws/appsre-prod.yml
  resources:
  - provider: terraform-repo
    repository: service/foo-repo
    ref: 1q2w3e4r5t
    path: appsre-prod
```

I specify `externalResources` here for time-to-solution purposes only. `externalResources` are scoped to an app-interface namespace file. The types of repos that are good targets for `terraform-repo` would be better served at the AWS account scope, and not related to a namespace. Creating a solution that allows for `terraformRepo` stanzas at the AWS account model scope makes sense as a future enhancement to this offering.

### What repositories are good targets?

There is a deeper discussion on repository requirements below, but it is important for the flow of this document to describe the types of terraform projects that are suitable for this integration.

__Engagements for terraform-repos are very specific and represent infrastructure problems that we do not have a scaleable solution for.__

The design intention for a repo should be as self-contained and free of dependencies as possible. I would not support a RDS database in a terraform-repo, as we have an existing solution in qontract-reconcile which performs the same activity.

Asset inputs to a terraform-repo should be very long lived and foundational (i.e. AppSRE VPC or similar). Created assets in a terraform-repo should be very precise: not addressed with an existing pattern we provide, highly specific to a tenant use case, long lived, and independent. `terraform-repo` targets represent the lowest level of coupling that AppSRE offers.

## Goals

* Execute terraform projects from an upstream git repository
* End users will compose projects from modules local to the git repository
* Support multi-account targeting though multiple project directories in the upstream
* Use app-interface as the orchestration layer, matching the current investment and approach in the target environment (FedRAMP)

## Non-Goals

* Replace terrascript-aws-client providers in qontract-reconcile
* Manage assets with a high degree of coupling - input variables, output variables, secrets
* Manage assets that already have q-r providers or would be better off served with a modular approach (rds databases, s3 buckets, etc.)
* Replace how we approach terraform on an org wide scale

## How

### Repository <> Account Targeting

Each `terraform-repo` project represents a bespoke, foundational, and slow-changing offering that does not fit into the current set of infrastructure abstractions.

By design, `terraform-repo` does not take advantage of qontract-reconcile providers that are instantiated across many AWS accounts. As discussed above in "Language Definitions", this pattern is an example of module and project concepts. To review, q-r providers are "modules" that are instantiated in N number of target accounts. The project in this context is the collection of all instantiated providers on a per-account basis.

Therefore, a solution must exist for deploying into multiple AWS accounts, since stage and production accounts are expected to be separate. Terraform modules can and should be used, however, to compose account-specific projects in a reusable way.

Engineers who author a terraform-repo project will create a modules directory and directories representing account-specific applications of the module, including variables that are unique to an account. I am purposely excluding the passing of environment specific variables from the app-interface context to the executor context (think things like cidr ranges, security group ids, and similar). Repositories that feature strong coupling, complex dependencies, or are not foundational in nature are not good candidates for the offering.

Therefore, terraform configurations that are used in multiple target accounts must follow this structure:

### Repository Directory Structure

```yaml
# Folder layout for service/foo-repo

./modules/<all terraform HCL module code lives here>
./stage-aws-account-name/main.tf
./integration-aws-account/main.tf
./production-aws-account-name/main.tf
./appsre-prod/main.tf
```

Linking this repository structure to the app-interface invocation:

```yaml
externalResources:
- provisioner:
    $ref: /aws/appsre-prod.yml
  resources:
  - provider: terraform-repo
    repository: service/foo-repo
    ref: 1q2w3e4r5t
    path: appsre-prod
```

In this example, we are running terraform apply on the `appsre-prod` sub-folder of the `service/foo-repo` repository at ref `1q2w3e4r5t`. The main.tf file in `./appsre-prod/main.tf` will look something like this:

```hcl
# main.tf

provider "aws" {}
backend "s3" {}

module "network" {
  source = "../modules/aws-network"

  base_cidr_block = "10.0.0.0/8"
}

output "module_output" {
  value = module.network.outputs
  type = map{}
}
```

I did consider terraform workspaces for multi-environment targeting. I find that a module approach and invocations of those modules has better long term portability and reduces the complexity of managing workspaces in addition to managing AWS account targets in the app-interface context. We have not used terraform workspaces in our commercial deployments over the lifetime of AppSRE terraform management, and I do not see a good reason to start to do so now.

### Repository Requirements

A repository that is eligible for usage with terraform-repo will need to meet a set of standard requirements. `terraform-repo` targets represent the lowest level of coupling that AppSRE offers.

The design intention for a repo should be as self-contained and free of dependencies as possible.  Created assets in a terraform-repo should be very precise: not addressed with an existing pattern we provide, highly specific to a tenant use case, long lived, and independent. 

Asset inputs to a terraform-repo should be very long lived and foundational.

Requirements include:

* Expected file / directory structure as discussed above
* Stand-alone (no remote data sources referencing other terraform states)
* Uses AWS provider + specified provider version
* Compatible with specified terraform version
* Uses environment variables to provide AWS provider with credentials
* Uses standardized partial configurations for backends which are fully configured during executor runs

### Executor

My goal with the first version of `terraform-repo` is to create something that works faster than something that is super sophisticated. I am not opposed to bash running on jenkins calling a terraform binary, if it gets us to revision 1 and a usable solution faster than Tekton + CDKTF. The goal is speed and providing the service, not necessarily making this our long term terraform solution.

If the ability to use the concepts and ideas in the solution in future iterations of our terraform service offering, then I find that to be a win. My discussion on repository requirements, directory structure, and usage of modules is written with the idea that we can leverage these pieces, regardless of what direction we move in the future.

To me, the executor matters little - what the executor is and how it functions should not be the focus. There are open source, paid 3rd party, and vendor solutions to the executor problem. I focus on speed to deliver for the executor.

On forward-compatibility:

* Tenants own the HCL. HCL is infinitely more portable and testable than terrascript, and is broadly understood by engineering peers.
* Given proper configuration, HCL can be run anywhere by anything. HCL execution is a lift and shift, terrascript generation / execution is tightly coupled and loses value outside of a qontract-reconcile context.

#### Operational Responsibilities

* Receive provider configuration from environment variables
* Receive backend configuration from environment variables
* Receive git repository target, sha ref, and target path from environment variables
* Git clone the repository target to local filesystem
* Checkout target branch at specified commit
* Cd into target path of target repository
* Run terraform init, providing backend and provider configurations during the invocation, either through cli options or environment variables
* Run terraform plan on the target directory
* Run terraform apply on the target directory
* Report status back to the job manager (Jenkins or Tekton)
* Capture output values and provide them to the job manager as appropriate

#### Executor Details

The executor will consist of a scripting language, a runtime environment, and terraform. The two contexts are merge request checks and ref updates in app-interface.

Script options:

* Bash
* Go
* Python

Runtime environment options:

* Jenkins
* Jenkins + Tekton
* Tekton

Terraform options:

* Terraform binary
* CDKTF

#### Recommendations for V1

Bash + Jenkins + TF Binary
 
If proven, 

Bash + Jenkins & Tekton + TF Binary

#### Environment Considerations

**Jenkins**

If a general-purpose job is possible to create, then the toil risk in using Jenkins for the integration is reduced greatly. I can see a future where 10+ projects are managed with this flow, and we have ever-growing complexity on the number of jobs used to support the effort. 

If a general-purpose job is not possible, then the goal would be to get this out the door for the first N repositories, followed by a strategy to replace this toil with a Tekton pipeline based approach.

With Jenkins, we will definitely use containerized builds, as this has future portability to Tekton. Personally, anything that takes us away from raw hosts running CI is a huge win. I am a big proponent of Tekton in this regard, but I do take into consideration the appetite of the team and the org for such a shift.

**Tekton**

A move to tekton for PR checks or merge jobs does make a lot of sense to me, but there are previously researched challenges and higher complexity with this approach.

In order to accept GitLab webhooks, we need to set up OpenShift routes and eventListeners for Tekton, as well as associate them with jobs. We have researched this in the past but have not implemented such a solution in AppSRE. Such a solution would be possible, but will come with time and schedule risks that must be considered when making a go/no go decision on Tekton.

There is some prior art from `anomaly-detection` service that takes advantage of tekton's `EventListener`.

Related reading:

* [Exposing an EventListener using Openshift Route](https://tekton.dev/docs/triggers/eventlisteners/#exposing-an-eventlistener-using-openshift-route)

### State Management

From terraform documentation: 

_“You do not need to specify every required argument in the backend configuration. Omitting certain arguments may be desirable if some arguments are provided automatically by an automation script running Terraform. When some or all of the arguments are omitted, we call this a partial configuration.”_

State management in terraform-repo will rely on repository-enforced partial backend configuration. See the full [docs](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#partial-configuration) on partial backend configuration.

The state management approach for this integration will be one state file per repository that lives in a shared state bucket associated on a per-account basis. A previously provisioned bucket (either through a bootstrap for a new account or an existing terraform resources backend bucket) will be used for repository runs. 

### Where does MR check success gate a merge?

This is a bit of a tricky detail in this flow, as the pr check job seems like it would naturally fit in a target git repository project. Alas, pr checks should gate promotions at the configuration scope (app-interface), instead of at the target repository scope. In addition, gating MR checks at the target repository scope open up the additional challenges of making state and account secrets available in the context of the MR check, which may take on additional development overhead with little obvious benefit.

Therefore, we should gate MR promotions to app-interface with terraform plan, and on a merge then execute terraform apply. From @anjaasta:

"It should be noted that there is little preventing a tenant from establishing their own MR checks on their own terraform-repo projects. There is some technical challenge in creating CI jobs and populating those jobs with the correct secrets to perform a terraform plan, but the challenge has prior art and established solutions. The focus should be on delivering the offering first, and then optimizing for quality-of-life concerns like in-repo MR/PR checks.
 
No matter what, the App-Interface MR level gating will always occur. But a tenant additionally establishing MR checks for their own repos will improve their own development feedback loops, and will also eliminate wasteful resource-and-executor-consuming MR builds detecting malformed HCL that could have been detected earlier at the tenant-repo-MR level."

### Development Flow

How does one develop against existing deployments of modules, or how does one bootstrap a totally new project?

Developers who are creating a terraform project for eventual management by terraform-repo will need a clear path for testing and deployment.

We expect stage and production account resources to be fully managed by terraform-repo. Therefore, integration is the developer test bed and provides a way for project owners to validate infrastructure changes before promoting with app-interface.

Credential management for integration environments should be handled by the project owner, in collaboration with AppSRE as deemed appropriate. Local state files can be used to simplify the secret management that will be managed by the integration for staging and production deployments.

I can see situations where integration accounts are not readily available. In these cases, a separate state bucket and separate provider credentials can be added to a stage environment in order to create a stable test environment for project work on the git repository itself. This would be isolated from the app-interface invocations of specific directories in the same repository.

#### Terraform workspaces and applicability to development needs

Alternatively, tenants could consider using `terraform workspaces` in the context of creating a development context. From @kfischer:

"Workspaces are very beneficial for development purposes in ephemeral setups and I would always recommend to take them into consideration when setting up a module. By using workspaces, multiple developers can work in parallel inside the same (integration) aws account."

Example of leveraging workspace in a resource:

```hcl
resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket-${terraform.workspace}"
  acl    = "private"
}
```

"By integrating ${terraform.workspace} into tenant projects code, tenants can achieve isolation to enable engineers to bootstrap and work on ephemeral environments in parallel."

### Timer-based reconciliation vs triggers

The primary reason for triggers over timer loops is that the ideal infrastructure targets for `terraform-repo` are foundational. Once provisioned, they should change at a very slow rate. The use case is unique, independent, loosely coupled, and as standalone as possible. We expect tenant apps to depend on `terraform-repo` projects, but we do not expect to manage resources that have a high rate of change.

We do lose on the constant drift reconciliation, but for `terraform-repo` appropriate projects, drift should not be the biggest risk. In an incident scenario with drift and a desire to return to an existing state, we can trigger a jenkins job or tekton pipeline to re-run the configuration.

I think the overhead cost (time, money) does not make the investment in time looped reconciliation worth it. However, if we run into situations where the trigger strategy turns out to not work as we expect, we can easily use our extensive prior art on timer-based reconciliation and apply it to this offering.
