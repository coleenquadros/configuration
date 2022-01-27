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

#### Parent target job running multiple times before the subscribed one.
Right now the job configuration state is stored just once for the last version of a saas `target` definition.
If there are multiple runs for the parent `target` before the automatic MR gets validated, it could end up with an invalid parent_config_hash.

```
Parent Target deployment Run: 1 -----> AutoPromote: 1 --------------> INVALID MR
Parent Target deployment Run: 2 -----> AutoPromote: 2 -----> Merged ---> Subscribed Target deployment Run
```

**SOLUTION:**\
If it's ok to just run the latest iteration, just close the invalid MR.

### Validate promotions fail at PR_Check
```
[2022-01-25 16:38:04] [ERROR] [saasherder.py:validate_promotions:1334] -
Promotion state object was generated with an old configuration of the parent job
```

This means that the `target_config_hash` set in the promotion data of the `target` does not match the hash
calculated on the parent `target` saas file.

### Failed parent Job run with a configuration change
Take this case as an example:\
Deploy Target (deploy_target) --> AutoPromotes Test Target (test_target)\

If `deploy_target` configuration is modified and its `PipelineRun` fails, the target's state will have the last configuration, but the subscribed target `test_target` won't contain the last configuration hash of `deploy_target`.  If at this point `test_target` configuration is modified in a manual pr, the pr_check will throw this error because the `target_config_hash` will not match. `test_target` target_config_hash references the configuration of the last successful `deploy_target` run.

**DIAGNOSIS**\
Check `deploy_target` PipelineRuns to check if there are failed jobs, try to git-history `deploy_target` saas file to see if that failed jobs correlates to a configuration change.
If all `deploy_target` deployment runs have failed after a configuration change and a `test_target` configuration change is throwing this error in a non-automated MR, you are mostly facing this problem

**SOLUTION**\
Ideally, subscribed jobs targets definitions should only be modified after a sucessful parent job run. If the job needs to run no mather what,
just remove the `promotion_data` section on the `test_target`.

## Useful debug information

* Promotions state S3 Path: s3://app-interface-production/state/openshift-saas-deploy/promotions/<CHANNEL>
* Saas targets Config state  S3 Path: s3://app-interface-production/state/openshift-saas-deploy-trigger-configs/<SAAS_FILE>
* Pipeline runs: Check the SAAS file for the `pipelines_provider` section. There is the cluster/namespace where to find the tekton PipelineRuns.
* Do git-history on saas file to try to understand the ref updates flow. If there are multiple jobs with subscribed targets it's a bit hard to trace what has happened.
