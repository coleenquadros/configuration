
# Inventory service shutdown procedure


## Workloads

The inventory service is comprised of 3 main workloads that each need to be scaled down.

  

- insights-inventory - the HTTP API

- inventory-mq-pmin - The low priority lane of the inventory's Kafka based API

- inventory-mq-p1 - The high priority



The workloads are designed to complete any in progress transactions before shutting down to avoid data discrepancies.


## Cron Jobs

Insights inventory also has one cron job, the `inventory-reaper`

If the reaper is currently running it can be shut down by killing any pods it's running in.

If the reaper has not yet started running you can keep it from running by suspending the job.

You can suspend the job with the following `oc` command. Note that if you suspend the reaper this way if the service is redeployed the reaper will no longer be suspended.

`oc patch cron-job inventory-reaper -p '{"spec" : {"suspend" : true }}'`

The reaper can also be suspended by setting the `REAPER_SUSPEND` environment variable to true in the inventory's `deploy.ym` file in the app-interface repo. Note that suspending the reaper this way will keep it suspended until the variable is set back to false. The reaper will stay suspended even if it is redeployed.