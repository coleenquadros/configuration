# Builds are not starting

## Diagnosing the issue

If no builds are running:

### Check the build queue

Run the following query in the database:

```
use quay;
select * from queueitem where queue_name like 'dockerfilebuild/%' and available=1 and retries_remaining > 0 and processing_expires > now();
```

If there are *many* builds and their `available_at` *keeps moving forward*, you likely have a Redis lockup.

### Check build manager logs

Check the build manager logs for statements like this:

`builder[102]: 2020-07-17 16:26:06,439 [102] [WARNING] [buildman.manager.ephemeral] Job: 1b93a26c-2f99-4687-a2dd-bba7e04b13aa already exists in orchestrator, timeout may be misconfigured`

If so, its likely Redis is filled with builds that are no longer running, and it is preventing new builds from being run.


## Fixing the issue

To fix this issue, all the existing keys within Redis must be flushed via the `FLUSHALL` command. There is a job that does this. After the flush operation all the quay pods need to be restarted

### Steps to fix

1. Update the `JOB_NAME` on the flush-redis job in the file `data/services/quayio/saas/quayio-utils.yaml`. [Example MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/30875)

2. Once the above change is merged and the job is complete. Restart the quay pods by updating the `QUAY_APP_COMPONENT_ANNOTATIONS_VALUE` variable [Example MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/31014/diffs)
