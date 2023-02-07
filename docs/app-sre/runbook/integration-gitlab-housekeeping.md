# Integration - GitLab Housekeeping

[TOC]

## Overview

The GitLab Housekeeping integration manages issues and merge requests on GitLab
projects. This includes rebasing and merging MRs for the app-interface repository.
Slowness in this integration becomes apparent to user quite quickly because they're
merge requests will not be merged.

## Metrics and Dashboards

Metrics with descriptions are defined in the integration
code [here](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/gitlab_housekeeping.py#L68)
. Notably, `qontract_reconcile_merge_requests_waiting`
and `qontract_reconcile_time_to_merge_merge_request_minutes` can tell us a lot of
information about how large the queue is, and how long it takes to merge MRs.

For instance, the following query would help us figure out what percentage of MRs have
been merged in <60 minutes:

```
sum(increase(qontract_reconcile_time_to_merge_merge_request_minutes_bucket{project_id="13582", le="60.0"}[1h])) 
 /
sum(increase(qontract_reconcile_time_to_merge_merge_request_minutes_bucket{project_id="13582", le="+Inf"}[1h]))
* 100
```

## Known Issues

### What is causing a large number of MRs to be queued?

In the current implementation, the integration will wait for the pipeline to complete
for the highest priority MR. If the MR continues to fail, this could result in a lot of
waiting time. Even if this issue is addressed, there could be other unexpected reasons
that could cause a lot of waiting on pipelines to finish (Jenkins performance issues).

The query below will show how many times the integration rechecked the status of the
pipeline. A large number of attempts for a single MR might suggest something happening
with that MR and the build pipelines.

```
fields @timestamp, message
| filter message like 'InsistOnPipelineError'
| parse message "[*] [*] [*] - Retrying - InsistOnPipelineError: Pipelines for merge request have not completed yet: *" as timest, log_level, code_line, mr_id
| display mr_id
| stats count(mr_id) as mr_id_count by mr_id
| sort by mr_id_count desc
| limit 10
```
