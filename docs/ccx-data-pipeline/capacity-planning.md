# Capacity Planning Document

## Production environment 

Follows a table with memory and CPU consumption for our production environment:


| Name                                    | CPU Requested | CPU Limit | Mem Requested | Mem Limit | Pods No. | CPU Req. Tot. | CPU Lim. Tot. | Meme Req. Tot. | Mem Lim. Tot. |
|-----------------------------------------|---------------|-----------|---------------|-----------|----------|---------------|---------------|----------------|---------------|
| ccx-data-pipeline-archives-handler      | 500m          | 1000m     | 512Mi         | 1024Mi    | 16       | 8000m         | 16000m        | 8192Mi         | 16384Mi       |
| ccx-insights-content-service            | 100m          | 250m      | 200Mi         | 400Mi     | 1        | 100m          | 250m          | 200Mi          | 400Mi         |
| ccx-insights-results-aggregator         | 100m          | 250m      | 500Mi         | 1000Mi    | 2        | 200m          | 500m          | 1000Mi         | 2000Mi        |
| ccx-insights-results-aggregator-cleaner | 200m          | 500m      | 256Mi         | 512Mi     | 1*       | 200m          | 500m          | 256Mi          | 512Mi         |
| ccx-insights-results-db-writer          | 100m          | 500m      | 600Mi         | 1200Mi    | 1        | 100m          | 500m          | 1200Mi         | 2400Mi        |
| ccx-notification-service                | 100m          | 500m      | 256Mi         | 512Mi     | 1*       | 100m          | 500m          | 256Mi          | 512Mi         |
| ccx-notification-writer                 | 100m          | 200m      | 256Mi         | 512Mi     | 1        | 100m          | 200m          | 256Mi          | 512Mi         |
| ccx-sha-extractor                       | 100m          | 200m      | 256Mi         | 512Mi     | 2        | 200m          | 400m          | 512Mi          | 1024Mi        |
| ccx-smart-proxy-service                 | 100m          | 250m      | 300Mi         | 600Mi     | 2        | 200m          | 500m          | 600Mi          | 1200Mi        |
| io-gathering-service                    | 100m          | 200m      | 256Mi         | 512Mi     | 2        | 200m          | 400m          | 512Mi          | 1024Mi        |
| total                                   |               |           |               |           | 29       | 9400m         | 19750m        | 12984Mi        | 25968Mi       |
**notes:**

* When "Pods No." is marked with an asterisk means that it's a CronJob 
(parallel execution of CronJobs is disabled everywhere.) 
* InitContainers are not reported in the table
* we increased hour [deployResources](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ccx-data-pipeline/deploy.yml#L17)

## Next Year Forecast

In the following table we will show the number of archive processed every week for this 
year:

| week_no | archives no. |
|---------|--------------|
| 1       | 655907       |
| 2       | 955166       |
| 3       | 962923       |
| 4       | 991587       |
| 5       | 1002588      |
| 6       | 1515334      |
| 7       | 1991168      |
| 8       | 2053327      |
| 9       | 2012236      |
| 10      | 2050178      |
| 11      | 2068409      |
| 12      | 2103241      |
| 13      | 1814761      |

Those numbers fluctuate quite a lot, however even at the peak of weekly archives 
received the pipeline managed to process without delays. Hence there's no plan 
for a significant resource increase. Moreover the bottleneck is the
ccx-insights-results-db-writer service that by design can not be horizontally scaled;
in this case we may increase the resources use by this single service if the need 
will arise in the future. As of this year the most significant increase in resource
usage was due to the introduction of two new services: ccx-sha-extractor and
io-gathering-service. We expect to introduce new features also in the future and
we're planning several optimizations to our most critical services.

## Stage environment 

| Name                                    | CPU Requested | CPU Limit | Mem Requested | Mem Limit | Pods No. | CPU Req. Tot. | CPU Lim. Tot. | Meme Req. Tot. | Mem Lim. Tot. |
|-----------------------------------------|---------------|-----------|---------------|-----------|----------|---------------|---------------|----------------|---------------|
| ccx-data-pipeline-archives-handler      | 500m          | 1000m     | 512Mi         | 1024Mi    | 2        | 1000m         | 2000m         | 1024Mi         | 2048Mi        |
| ccx-insights-content-service            | 100m          | 250m      | 200Mi         | 400Mi     | 1        | 100m          | 250m          | 200Mi          | 400Mi         |
| ccx-insights-results-aggregator         | 100m          | 250m      | 500Mi         | 1000Mi    | 2        | 200m          | 500m          | 1000Mi         | 2000Mi        |
| ccx-insights-results-aggregator-cleaner | 200m          | 500m      | 256Mi         | 512Mi     | 1*       | 200m          | 500m          | 256Mi          | 512Mi         |
| ccx-insights-results-db-writer          | 100m          | 500m      | 600Mi         | 1200Mi    | 1        | 100m          | 500m          | 1200Mi         | 2400Mi        |
| ccx-notification-service                | 100m          | 500m      | 256Mi         | 512Mi     | 1*       | 100m          | 500m          | 256Mi          | 512Mi         |
| ccx-notification-writer                 | 100m          | 200m      | 256Mi         | 512Mi     | 1        | 100m          | 200m          | 256Mi          | 512Mi         |
| ccx-sha-extractor                       | 100m          | 200m      | 256Mi         | 512Mi     | 1        | 100m          | 200m          | 256Mi          | 512Mi         |
| ccx-smart-proxy-service                 | 100m          | 250m      | 300Mi         | 600Mi     | 2        | 200m          | 500m          | 600Mi          | 1200Mi        |
| io-gathering-service                    | 100m          | 200m      | 256Mi         | 512Mi     | 1        | 100m          | 200m          | 256Mi          | 512Mi         |
| total                                   |               |           |               |           | 13       | 2200m         | 5350m         | 5304Mi         | 10608Mi       |

we do not need, except for new services, more resources for this invironment

## Databases

definitions of our two databases:

[ccx-data-pipeline-db](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/postgres11-rds-1.yml)

[ccx-notification-db](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/ccx-pg11-rds.yml)

We are resonably comfortable that the storage allocated for us so far will be enough
entering the next year as well.


