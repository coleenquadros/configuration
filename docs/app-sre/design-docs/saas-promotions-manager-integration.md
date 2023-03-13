# Design document - SaaS Auto Promotions Manager Integration

[toc]

## Author / Date

Karl Fischer
March 2023

## Tracking JIRA

[APPSRE-6941](https://issues.redhat.com/browse/APPSRE-6941)

## Problem statement

We often see merge conflicts in auto-promotion MRs created by our devtools bot.

Auto promotion MRs are currently created after a tekton deployment pipeline successfully
finished a deployment job. Tekton pipelines are not fully context aware, i.e., they
do not know the current state of open MRs. Further, pipelines can potentially run in parallel, which makes it even harder to gain full context.

An auto promotion process can take some time and involve multiple MRs.
If during that time another deployment happened in the publisher target, then a potentially
parallel auto promotion process is started, resulting in MRs that have merge conflicts.

### Current Implementation

![](images/saas-auto-promotions-manager/current.png)

### Issue

The following timeline highlights how multiple parallel promotions can result in merge conflicts. In essence, a new promotion MR is opened before a previous promotion MR got merged for the same saas target.

![](images/saas-auto-promotions-manager/issue.png)

## Goals

* Solution to avoid merge conflicts in auto-promotions

## Non-Goals

* Do not replace current saas-trigger integrations. Solely focus on auto-promotions.

## Proposal

Create a new fully context aware integration: `saas-auto-promotions-manager` (SAPM). Remove auto-promotion feature from openshift-saas-deploy. SAPM is able to gather all context around auto-promotions:

- whats the commit sha of a saas file target ref?
- is there a successful deployment for a new commit sha?
- are there already open MRs for the subscribed target?

![](images/saas-auto-promotions-manager/proposal.png)

## Alternatives Considered

- leverage timestamps from deployment state instead of querying VCSs directly. We decided against that because a timestamp does not guarantee a proper order of commits. (a pipeline might be very slow)

## Milestones

1. SAPM re-creates current behavior and replaces openshift-saas-deploy auto-promotion feature.
2. SAPM manages MRs to avoid merge conflicts.
