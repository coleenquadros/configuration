# Inventory service shutdown procedure


## Workloads

The Inventory service is comprised of 3 main workloads that each need to be scaled down:

  

- insights-inventory - The HTTP API

- inventory-mq-pmin - The low priority lane of the inventory's Kafka based API

- inventory-mq-p1 - The high priority lane of the inventory's Kafka based API



The workloads are designed to complete any in-progress transactions before shutting down to avoid data discrepancies.


## Cron Jobs

Insights inventory also has one cron job, named `inventory-reaper`.

If the reaper is currently running, it can be shut down by killing any of the pods it's running in.

If the reaper has not yet started, you can keep it from running by suspending the job.

You can suspend the job with the following `oc` command:

`oc patch cron-job inventory-reaper -p '{"spec" : {"suspend" : true }}'`

Note that if you suspend the reaper this way, it will resume the next time the service is deployed.


The reaper can also be suspended by setting the `REAPER_SUSPEND` environment variable to 'true' in host-inventory's `deploy.yml` file in the app-interface repo. Suspending the reaper this way will keep it suspended until the variable is set back to false, even if the service is redeployed.
