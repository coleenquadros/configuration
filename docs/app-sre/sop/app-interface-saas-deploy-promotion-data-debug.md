# SAAS target automatic deployments

[TOC]

## Background
Saas `targets` promotion_data section is managed automatically by `openshift-saas-deploy` to keep track
of the parent `target` configuration and to trigger jobs when there are configuration changes in
parent `targets` others than the `ref`.

**More information:**

* [saas_walkthrough](/docs/app-sre/saas-walkthrough.md#automated-promotions-with-configuration-changes)
* [continuous-delivery](/docs/app-sre/continuous-delivery-in-app-interface-md)

## Purpose

This SOP is intended to be useful to diagnose problems in automatic saas promotions

## Failure scenarios

### Branch cannot be rebased by the bot

#### Parent target job running multiple times before the promoted one.
If there are multiple runs for the parent `target` before the automatic MR gets merged, the MR could end up with rebase conflicts.

```
Parent Target deployment Run: 1 -----> AutoPromote: 1 ---------------> INVALID MR
Parent Target deployment Run: 2 -----> AutoPromote: 2 -----> Merged -----> Subscribed Target deployment Run
```

**SOLUTION:**\
* Just close the invalid MR. The full pipline has run on a newer path.

### Validate promotions fails at PR_Check
```
[2022-01-25 16:38:04] [ERROR] [saasherder.py:validate_promotions:1334] -
Parent saas target has run with a newer configuration and the same commit (ref). Check if other MR exists for this target"
```

This means that the `target_config_hash` set in the promotion data of the `target` does not match the hash set in the parent `target` promotion state. This could only happen
if a configuration change has been introduced in the parent `target` and its job has finished before the auto-promote MR showing this error. It shuold exist a newer MR
with the same `ref` and with the newer `target_config_hash`.


**SOLUTION:**\
* If a new MR exists, just close the problematic one.

### Generic Problem

`promotion_data` primary objective is to trigger subscribed targets when there are configuration changes others than `ref` in the parent. It's basically introduced to
generate a change in the saas file to trigger its deployment. If, for whatever reason, the `promotion_data` is failing the validation and the subscribed job needs to run,
it's safe to just remove the `promotion_data` section to trigger the job. If `promotion_data` is missing, the validate_promotions will only validate the parent target has
ended succesfully with the same `ref`, without validating the configuration hash.
`

## Useful debug information

* Promotions state S3 Path: s3://app-interface-production/state/openshift-saas-deploy/promotions/<CHANNEL>
* Saas targets Configurations S3 Path: s3://app-interface-production/state/openshift-saas-deploy-trigger-configs/<SAAS_FILE>
* Pipeline runs: Check the SAAS file for the `pipelines_provider` section. There is the cluster/namespace where to find the tekton PipelineRuns.
* Do git-history on saas files to try to understand the ref updates flow. If there are multiple jobs with subscribed targets it's a bit hard to trace what has happened.
