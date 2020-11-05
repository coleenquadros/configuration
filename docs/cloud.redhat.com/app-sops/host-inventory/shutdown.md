# Inventory service shutdown procedure

## Workloads
The inventory service is comprised of 3 main workloads that each need to be scaled down.

 - insights-inventory - the HTTP API
 - inventory-mq-pmin - The low priority lane of the inventory's Kafka based API
 - inventory-mq-p1 - The high priority

The workloads are designed to complete any in progress transactions before shutting down to avoid data discrepancies.

## Cron Jobs
Insights inventory also has one cron job, the `inventory-reaper`.

You can suspend the job with the following `oc` command

`oc patch cron-job inventory-reaper -p '{"spec" : {"suspend" : true }}'`

If the reaper needs to be suspended for a long period of time, and remain suspended after redeployment/updates to the inventory service, the `REAPER_SUSPEND` environment variable can be set to true in the inventory's deploy.yml in app-sre
