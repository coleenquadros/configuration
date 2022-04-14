# cloudigrade load testing

## Overview

This document describes a series of ad-hoc manual load and performance tests and measurements performed by the cloudigrade dev team in April 2022. At the time of this writing, cloudigrade does not have automated processes to exercise load and performance tests. If the dev team produces related automation or performs additional ad-hoc tests in the future, this document will be updated with that information.

## Brief summary of test results

- The response times of the most actively used `sysconfig` and `concurrent` APIs _are not_ significantly affected by the number of users and their activity (comparing results at prod-like and 2x-prod-like database sizes).
- The response times of the most actively used `sysconfig` and `concurrent` APIs _are_ affected by the number of running pods when handling a large number of parallel requests.
- Application-level logging using Watchtower _incurs a performance penalty_ accounting for between 5% and 90% of the total response time depending on which action is being exercised.
- AWS RDS/PostgreSQL disk use grows linearly in relation to number of users and their activity.
- AWS ElastiCache/Redis memory usage grows linearly in relation to number of users and their activity.

----

## Areas of potential concern

As of April 2022, the cloudigrade dev team has identified the following areas of potential concern with regards to performance, load, and scalability:

1. Lack of Horizontal Pod Autoscaling (HPA)
2. AWS CloudWatch performance
3. AWS RDS/PostgreSQL size and performance
4. AWS ElastiCache/Redis size

### Lack of Horizontal Pod Autoscaling (HPA)

console.redhat.com platform services have been strongly recommended to deploy to OpenShift using Clowder. However, Clowder does not allow services to define meaningful Horizontal Pod Autoscaling resources. This means that we have to define a static number of pods for each deployment, and we have to manually adjust that number if a need arises. The cloudigrade devs have been asking and waiting for any kind of supported solution to this limitation for more than six months, since October 2021, and no solution is expected to be available in the foreseeable future.

Because pod counts cannot scale horizontally automatically, cloudigrade's deployments cannot automatically respond to increased load. This severely limits cloudigrade's performance and ability to serve requests during periods of increased load. This limitation affects all operations of the HTTP APIs and Celery workers.

### AWS CloudWatch

console.redhat.com platform services have been strongly recommended to implement application-level logging to AWS CloudWatch because no other centralized platform-level logging is made available to us. Although SRE does collect all logs in its own AWS CloudWatch log groups, application teams are forbidden from accessing those logs in any meaningful way, and as a result, we must incur the additional costs (both in monetary terms and service performance) of recording the logs a second time if we want to preserve any logs for later review.

To capture logs at the application level, cloudigrade uses the [Watchtower](https://kislyuk.github.io/watchtower/) library to transmit to AWS CloudWatch. Unfortunately, to ensure prompt and complete delivery of _all_ messages to AWS CloudWatch, we must run Watchtower with `use_queues=False` which results in Watchtower _synchronously_ transmitting to AWS CloudWatch. This adds latency to any operations that produce log messages, and nearly all of cloudigrade's APIs and tasks produce some logs.

### AWS RDS (PostgreSQL)

AWS RDS (PostgreSQL) is cloudigrade's primary data store. cloudigrade uses a single database for all users in a given environment, relying on application-level multitenancy separation and enforcement.

We expect database storage requirements to grow linearly with the number of users, users' number of instances, and instances' amount of activity (e.g. "on" and "off" state changes). During normal operation, cloudigrade executes many `SELECT` and `INSERT` operations as it records and aggregates usage data for reporting, but it executes significantly fewer `UPDATE` or `DELETE` operations. cloudigrade generally only deletes data when a customer has chosen to completely remove (not just disable) their source from console.redhat.com.

Because database relations for cloudigrade will continue to grow as the number of users and their activities also grow, we expect cloudigrade to eventually need RDS's available storage to grow as well.

### AWS ElastiCache (Redis)

AWS ElastiCache (Redis) is cloudigrade's primary message broker for its asynchronous task processor. Because ElastiCache is an in-memory database, its utility is constrained chiefly by the instance's available memory, not its disk space. The overwhelming majority of cloudigrade's data-processing operations execute in asynchronous Celery tasks, for which ElastiCache is the configured message broker. Messages for asynchronous tasks reside in ElastiCache until they are processed by a Celery worker, after which the original message is deleted and a receipt is pushed back into ElastiCache for approximately 24 hours.

We expect memory requirements to grow linearly (though at a slower rate than RDS's storage) with the number of users and their activity. During normal operation, cloudigrade creates and processes many tasks at a generally steady rate throughout the day. Some of these tasks are created on periodic schedules, and some of them are created as side-effects of customer-driven activity in the public cloud accounts that cloudigrade is monitoring. Tasks are generally created on a per-user or per-cloud-account basis, though some tasks are created on a per-image basis when cloudigrade discovers the first use a new image.

Because the number of tasks (and therefore ElastiCache messages) for cloudigrade will continue to grow as the number of users and their activities also grow, we expect cloudigrade to eventually need ElastiCache's available memory to grow as well.

----

## Setup and test methodology

cloudigrade devs performed an exercise in April 2022 to synthesize data in the stage environment to roughly mimic the scale and behavior of data measured in the prod environment. This is a time-consuming exercise and should only be performed by the cloudigrade devs while actively monitoring the state of the systems involved because improper use may result in exhausting RDS or ElastiCache resources which would cause stage service outages and block cloudigrade's automated CI/CD processes.

We counted the number of certain relations in the prod database, which at the time were:

- `258` total User objects (`SELECT count(1) FROM auth_user`)
- `284` total CloudAccount objects (`SELECT count(1) FROM api_cloudaccount`)
- `5426` total MachineImage objects (`SELECT count(1) FROM api_machineimage`)
- `144728` total Instance objects (`SELECT count(1) FROM api_instance`)
- `187638` total Run objects (`SELECT count(1) FROM api_run`)
- `39683` total ConcurrentUsage objects (`SELECT count(1) FROM api_concurrentusage`)

We can infer from this data that on average:

- each user had `1.1` cloud accounts with activity spanning `153` days
- each cloud account had `510` instances
- each cloud account used `19` images
- each instance had `1.3` runs
- each image was used by `27` instances
- each day each user had an average of `3.6` instances and `4.7` runs

We built and used an internal API to synthesize data in the stage environment to _approximate_ those prod counts. We used a local script to request data be synthesized for one user, wait until all data was ready, and repeat for a total of `258` new users. Each of those API request looked like the following example:

```sh
SINCE_DAYS_AGO=153
INSTANCE_COUNT=510
RUNS_PER_INSTANCE=1.3
IMAGE_COUNT=19
IMAGE_RHEL_CHANCE=1.0
EXPIRES_AT=$(gdate --date="+7 days" -u "+%Y-%m-%dT%H:%M:%S")

http "${HTTP_PROXY}" --cert="${CERTPATH}" --cert-key="${CERTKEYPATH}" \
    https://mtls.internal.cloud.stage.redhat.com/api/cloudigrade/internal/api/cloudigrade/v1/syntheticdatarequests/ \
        cloud_type=aws \
        since_days_ago="${SINCE_DAYS_AGO}" \
        account_count="${ACCOUNT_COUNT}" \
        instance_count="${INSTANCE_COUNT}" \
        image_count="${IMAGE_COUNT}" \
        run_count_per_instance_mean="${RUNS_PER_INSTANCE}" \
        image_rhel_chance="${IMAGE_RHEL_CHANCE}" \
        expires_at="${EXPIRES_AT}"
```

After completing the initial bulk data synthesis, we performed various measurements and load tests (explained later below), and then synthesized a second bulk of data before repeating some of those measurements. This second set of synthesized data was _in addition_ to the first set, meaning we put approximately twice as much data into the stage environment as what was then present in the prod environment.

To measure HTTP response times, our tests used a combination of JMeter and bespoke Python code. We used JMeter for tests that needed to simulate many simultaneous parallel requests, and we used the simpler Python code when we just needed to measure serial requests from one user.

**Important Notes:**

- The stage environment did not have available resources allocated equal to the prod environment. We tried to minimize the effects of the different resource scale in our tests and analysis, but this is not a perfect science.
- After completing data synthesis in stage, we executed a `VACUUM FULL` on the stage database because the database tables were very fragmented and oversized due to several previous started and aborted data synthesis attempts. In a more ideal, controlled testing environment, we would have started with a clean, empty database and would not have needed this `VACUUM FULL`, but that option was not available at the time. Also, the manner in which we synthesized data over a _few minutes_ was, by its very nature, incongruent with the "natural" accumulation of data for a user over _several months_. By performing a `VACUUM FULL` to compact the files, we got a more accurate representation of the real _minimum_ effects on data storage.

----

## Results and interpretation

The following sections are split among the previously discussed areas of potential concern, with tests focusing specifically on measuring the impact on that area.

### Lack of Horizontal Pod Autoscaling (HPA)

We used JMeter to fetch the `concurrent` API for a specific user in various combinations of series and parallel requests. The `concurrent` API was a good candidate for testing because it was the more complex of cloudigrade's two most frequently accessed APIs (the other being `sysconfig`, which simply returned the same JSON object for all authenticated users). The `concurrent` API performed a few database queries based on the user and optional arguments, and it returned the results as JSON.

All JMeter tests here were performed from an external machine via a gitabit fiber network connection, and the tests never came close to saturating either the available upstream or downstream bandwidth.

Requesting with an increasing number of concurrent threads, with each thread looping 300 times, we observed:

| threads | avergage (ms) | median (ms) | throughput/minute |
| ------- | ------------- | ----------- | ----------------- |
| 1       | 84            | 73          | 712               |
| 1       | 96            | 82          | 623               |
| 1       | 86            | 77          | 689               |
| 2       | 103           | 80          | 1158              |
| 2       | 105           | 80          | 1088              |
| 2       | 99            | 82          | 1190              |
| 3       | 134           | 97          | 1307              |
| 3       | 134           | 106         | 1334              |
| 3       | 127           | 105         | 1368              |
| 4       | 174           | 148         | 1343              |
| 4       | 159           | 141         | 1480              |
| 4       | 171           | 151         | 1379              |
| 6       | 244           | 210         | 1458              |
| 6       | 227           | 203         | 1548              |
| 6       | 207           | 194         | 1685              |
| 8       | 279           | 255         | 1674              |
| 8       | 271           | 252         | 1718              |
| 8       | 274           | 248         | 1717              |
| 10      | 312           | 331         | 1768              |
| 10      | 326           | 294         | 1682              |
| 10      | 327           | 285         | 1655              |
| 15      | 518           | 498         | 1687              |
| 15      | 527           | 491         | 1669              |
| 15      | 559           | 503         | 1563              |
| 20      | 736           | 697         | 1581              |
| 20      | 757           | 732         | 1561              |
| 20      | 647           | 611         | 1818              |

As the number of concurrent requests (threads) increased, the throughput increased briefly before plateauing. During these periods of parallel requests, CPU usage as reported by OpenShift and seen in Prometheus and Grafana also increased. Note that we had only 2 API pods running in stage at the time of this test. If Clowder supported autoscaling, OpenShift should have created additional pods to better handle that additional load. Since Clowder does not support autoscaling, though, the throughput flattened and response times suffered as the parallelism increased.

We repeated this exercise after synthesizing an additional prod-sized set of customer data, and the results were effectively the same. This suggests that the general response time of the `concurrent` API were not significantly affected by the cardinality of the underlying customer data. Below is a minimal representative set of results from that second set of tests:

| threads | avergage (ms) | median (ms) | throughput/minute |
| ------- | ------------- | ----------- | ----------------- |
| 1       | 85            | 71          | 700               |
| 2       | 97            | 18          | 1187              |
| 3       | 140           | 115         | 1198              |
| 4       | 150           | 110         | 1545              |
| 6       | 201           | 189         | 1757              |
| 8       | 271           | 223         | 1712              |
| 10      | 330           | 284         | 1681              |
| 15      | 506           | 480         | 1741              |
| 20      | 688           | 701         | 1707              |


### AWS CloudWatch

Because cloudigrade emits logs at all levels of operation, to measure the latency induced by Watchtower's synchronous calls to CloudWatch, we timed three types of operations with Watchtower enabled and disabled:

- requests to public HTTP API `sysconfig`
- requests to public HTTP API `concurrent`
- requests to internal HTTP API `syntheticdatarequest`

The `sysconfig` API is the primary (and possibly only) cloudigrade API that Red Hat customers directly interact with. The customer's web browser makes a request to `sysconfig` during their initial source creation process. This API logs a few general informational messages and makes one database query. We can emulate a customer requesting this API 500 times using commands like:

```sh
# known synthetic account number
ACCOUNT="SYNTHETIC-edcdff83-da04-4594-a52c-7a1184ae4b59"
IDENTITY=$(echo -n '{"identity": {"account_number": "'${ACCOUNT}'","user": {"is_org_admin": true}}}' | base64 -w0)
python -m timeit -v -n100 -r5 -s'import requests' "requests.get('http://localhost:8000/api/cloudigrade/v2/sysconfig/', headers={'x-rh-identity': '${IDENTITY}'})"
```

- Watchtower/CloudWatch enabled:
    - average response time: 13.1 ms/request
        ```
        raw times: 13.6 sec, 13 sec, 12.6 sec, 12.9 sec, 13.3 sec

        100 loops, best of 5: 126 msec per loop
        ```

- Watchtower/CloudWatch disabled:
    - average response time: 12.2 ms/request (7% faster)
        ```
        raw times: 12.2 sec, 12.1 sec, 12.3 sec, 12.3 sec, 12.2 sec

        100 loops, best of 5: 121 msec per loop
        ```

The `concurrent` API is the other most active public cloudigrade API; the Subscription Watch service polls this API nightly with several thousand serial (not parallel) requests. Some of the requests have identities that cloudigrade does not know. So, we have two versions of the same type of request:

```sh
# known synthetic account number
ACCOUNT="SYNTHETIC-edcdff83-da04-4594-a52c-7a1184ae4b59"
IDENTITY=$(echo -n '{"identity": {"account_number": "'${ACCOUNT}'","user": {"is_org_admin": true}}}' | base64 -w0)
python -m timeit -v -n100 -r5 -s'import requests' "requests.get('http://localhost:8000/api/cloudigrade/v2/concurrent/', params={'start_date':'2022-04-04', 'end_date':'2022-04-05'}, headers={'x-rh-identity': '${IDENTITY}'})"
```

```sh
# known invalid account number
BOGUS_IDENTITY=$(echo -n '{"identity": {"account_number": "bogus","user": {"is_org_admin": true}}}' | base64 -w0)
python -m timeit -v -n100 -r5 -s'import requests' "requests.get('http://localhost:8000/api/cloudigrade/v2/concurrent/', params={'start_date':'2022-04-04', 'end_date':'2022-04-05'}, headers={'x-rh-identity': '${BOGUS_IDENTITY}'})"
```

- Watchtower/CloudWatch enabled:
    - average: 70.8 ms/request
        ```
        raw times: 7.49 sec, 6.49 sec, 6.9 sec, 7.32 sec, 7.2 sec

        100 loops, best of 5: 64.9 msec per loop
        ```
    - average: 56.7 ms/request
        ```
        raw times: 5.39 sec, 5.33 sec, 5.31 sec, 5.61 sec, 5.7 sec

        100 loops, best of 5: 53.1 msec per loop
        ```
- Watchtower/CloudWatch disabled:
    - average: 62.9 ms/request (**11% faster**)
        ```
        raw times: 6.6 sec, 6.11 sec, 5.98 sec, 6.51 sec, 6.29 sec

        100 loops, best of 5: 59.8 msec per loop
        ```
    - average: 48.8 ms/request (**14% faster**)
        ```
        raw times: 4.91 sec, 4.9 sec, 4.91 sec, 4.68 sec, 5 sec

        100 loops, best of 5: 46.8 msec per loop
        ```

The `sysconfig` and `concurrent` API response times improved by 1-15 msec each, which in isolation may not seem like much, but these two high-visibility APIs already have very few log messages, and therefore removing the log latency for logging only showing a small improvement is to be expected.

The `syntheticdatarequest` API itself does not emit many logs; however, it results in thousands of new Celery tasks that in turn will emit many thousands more log messages as they are processed. We posted 10 requests to that API (like the example at the start of "Testing and Analysis"), waited for each of their data synthesis tasks to complete, and then measured the differences in time between their first and last object creations.

```psql
-- include IDs that were created with Watchtower enabled (787-796)
SELECT EXTRACT (EPOCH FROM min(delta)) as min_sec
    , EXTRACT (EPOCH FROM max(delta)) as max_sec
    , EXTRACT (EPOCH FROM sum(delta)/count(delta)) AS avg_sec
FROM (
        SELECT (max(u.created_at) - r.created_at) AS delta
        FROM api_syntheticdatarequest r JOIN api_concurrentusage u USING (user_id)
        WHERE r.id BETWEEN 787 AND 796 AND u.date <= '2022-04-11'
        GROUP BY r.created_at
) a;

-- include IDs that were created with Watchtower disabled (797-806)
SELECT EXTRACT (EPOCH FROM min(delta)) as min_sec
    , EXTRACT (EPOCH FROM max(delta)) as max_sec
    , EXTRACT (EPOCH FROM sum(delta)/count(delta)) AS avg_sec
FROM (
        SELECT (max(u.created_at) - r.created_at) AS delta
        FROM api_syntheticdatarequest r JOIN api_concurrentusage u USING (user_id)
        WHERE r.id BETWEEN 797 AND 806 AND u.date <= '2022-04-11'
        GROUP BY r.created_at
) a;
```

- Watchtower/CloudWatch enabled:
    - Each synthesized data request required on average 166.1 seconds.
        ```
          min_sec   |  max_sec   |  avg_sec
        ------------+------------+------------
         135.256994 | 201.585366 | 166.126495
        ```
- Watchtower/CloudWatch disabled:
    - each synthesized data request required on average 15.0 seconds (**_11x_ faster**)
        ```
          min_sec  |  max_sec  | avg_sec
        -----------+-----------+----------
         10.809389 | 25.385605 | 15.01354
        ```

Those reported numbers aren't outliers; we really did save 90+% processing time by disabling Watchtower. We had been synthesizing lots of data in small and large batches leading up to this exercise, and these numbers are entirely inline with those recent experiences. This evidence underscores the need for a truly hands-off and _asynchronous_ log shipping service as part of the console.redhat.com platform.


### AWS RDS (PostgreSQL)

To check the approximate disk usage for each of cloudigrade's database relations, connect to the database and perform the following query:

```psql
SELECT c.oid
    , nspname || '.' || relname AS "relation"
    , c.reltuples AS "row_estimate"
    , pg_total_relation_size(c.oid) AS "total_bytes"
    , pg_size_pretty(pg_total_relation_size(c.oid)) AS "total_pretty"
FROM
    pg_class c
    LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE
    nspname NOT IN ('pg_catalog', 'information_schema')
    AND c.relkind <> 'i'
    AND nspname !~ '^pg_toast'
ORDER BY pg_total_relation_size(c.oid) DESC
LIMIT 20;
```

To check the approximate disk usage for all relations combined:

```psql
SELECT sum(pg_total_relation_size(c.oid)) AS "total_bytes"
    , pg_size_pretty(sum(pg_total_relation_size(c.oid))) AS "total_pretty"
FROM pg_class c LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace);
```

Running the above queries on the prod database on 2022-04-11 gave the following results:

```
  oid  |                      relation                       | row_estimate | total_bytes | total_pretty
-------+-----------------------------------------------------+--------------+-------------+--------------
 16624 | public.api_instanceevent                            |       855556 |   229515264 | 219 MB
 16983 | public.api_concurrentusage_potentially_related_runs |       119068 |   157491200 | 150 MB
 16585 | public.api_awsinstanceevent                         |       855556 |   109371392 | 104 MB
 16645 | public.api_run                                      |       191519 |    64561152 | 62 MB
 16615 | public.api_instance                                 |       148025 |    60948480 | 58 MB
 16572 | public.api_awsinstance                              |       144735 |    31416320 | 30 MB
 16964 | public.api_concurrentusage                          |        41842 |    15663104 | 15 MB
 16633 | public.api_machineimage                             |         5570 |     4087808 | 3992 kB
 16450 | public.auth_user                                    |            0 |     3743744 | 3656 kB
 17499 | public.api_instancedefinition                       |            0 |     1712128 | 1672 kB
 16593 | public.api_awsmachineimage                          |         5497 |     1622016 | 1584 kB
 16850 | public.django_celery_beat_periodictask              |           12 |     1236992 | 1208 kB
 16552 | public.api_awscloudaccount                          |          291 |      729088 | 712 kB
 16738 | public.api_machineimageinspectionstart              |         3545 |      655360 | 640 kB
 17079 | public.api_usertasklock                             |          262 |      376832 | 368 kB
 16826 | public.health_check_db_testmodel                    |           15 |      237568 | 232 kB
 16606 | public.api_cloudaccount                             |          293 |      155648 | 152 kB
 16651 | public.api_awsmachineimagecopy                      |            0 |      155648 | 152 kB
 16424 | public.auth_permission                              |            0 |       90112 | 88 kB
 16834 | public.django_celery_beat_crontabschedule           |            0 |       65536 | 64 kB
```
and
```
 total_bytes | total_pretty
-------------+--------------
  1102872576 | 1052 MB
```

The same queries in stage after synthesizing the _first_ set of data and performing a `VACUUM FULL`:

```
  oid  |                      relation                       | row_estimate | total_bytes | total_pretty
-------+-----------------------------------------------------+--------------+-------------+--------------
 16731 | public.api_instanceevent                            |       381311 |    70148096 | 67 MB
 16752 | public.api_run                                      |       188581 |    40132608 | 38 MB
 16692 | public.api_awsinstanceevent                         |       381311 |    40116224 | 38 MB
 16679 | public.api_awsinstance                              |       147115 |    39714816 | 38 MB
 16917 | public.api_concurrentusage                          |        43149 |    30040064 | 29 MB
 16936 | public.api_concurrentusage_potentially_related_runs |       200146 |    28139520 | 27 MB
 16722 | public.api_instance                                 |       147115 |    22306816 | 21 MB
 16740 | public.api_machineimage                             |         5264 |     2211840 | 2160 kB
 17176 | public.api_instancedefinition                       |         1167 |     1622016 | 1584 kB
 16700 | public.api_awsmachineimage                          |         5189 |     1540096 | 1504 kB
 35302 | public.api_syntheticdatarequest_machine_images      |         5111 |      778240 | 760 kB
 16659 | public.api_awscloudaccount                          |          282 |      172032 | 168 kB
 16457 | public.auth_user                                    |          272 |      147456 | 144 kB
 16575 | public.django_celery_beat_periodictask              |           12 |      131072 | 128 kB
 16713 | public.api_cloudaccount                             |          282 |      114688 | 112 kB
 16985 | public.health_check_db_testmodel                    |          357 |       90112 | 88 kB
 35288 | public.api_syntheticdatarequest                     |          269 |       73728 | 72 kB
 16431 | public.auth_permission                              |          144 |       65536 | 64 kB
 17077 | public.api_usertasklock                             |            3 |       40960 | 40 kB
 16845 | public.api_machineimageinspectionstart              |           99 |       40960 | 40 kB
```
and
```
 total_bytes | total_pretty
-------------+--------------
   409141248 | 390 MB
```

The same queries in stage after synthesizing the _second_ set of data and performing a `VACUUM FULL`:
```
  oid  |                      relation                       | row_estimate | total_bytes | total_pretty
-------+-----------------------------------------------------+--------------+-------------+--------------
 16731 | public.api_instanceevent                            |       752963 |   138518528 | 132 MB
 16752 | public.api_run                                      |       374442 |    79683584 | 76 MB
 16692 | public.api_awsinstanceevent                         |       752963 |    79634432 | 76 MB
 16679 | public.api_awsinstance                              |       288892 |    78725120 | 75 MB
 16917 | public.api_concurrentusage                          |        86520 |    60637184 | 58 MB
 16936 | public.api_concurrentusage_potentially_related_runs |       401656 |    56418304 | 54 MB
 16722 | public.api_instance                                 |       288892 |    43769856 | 42 MB
 16740 | public.api_machineimage                             |        10545 |     4276224 | 4176 kB
 16700 | public.api_awsmachineimage                          |        10470 |     3031040 | 2960 kB
 17176 | public.api_instancedefinition                       |         1167 |     1622016 | 1584 kB
 35302 | public.api_syntheticdatarequest_machine_images      |        10393 |     1507328 | 1472 kB
 16659 | public.api_awscloudaccount                          |          581 |      319488 | 312 kB
 16457 | public.auth_user                                    |          550 |      237568 | 232 kB
 16713 | public.api_cloudaccount                             |          581 |      212992 | 208 kB
 35288 | public.api_syntheticdatarequest                     |          547 |      147456 | 144 kB
 16575 | public.django_celery_beat_periodictask              |           12 |      131072 | 128 kB
 16431 | public.auth_permission                              |          144 |       65536 | 64 kB
 16845 | public.api_machineimageinspectionstart              |           98 |       40960 | 40 kB
 16758 | public.api_awsmachineimagecopy                      |            7 |       40960 | 40 kB
 17077 | public.api_usertasklock                             |            3 |       40960 | 40 kB
```
and
```
 total_bytes | total_pretty
-------------+--------------
   794206208 | 757 MB
```

These results confirm our expectation that database disk use will grow in linear correlation to the growing number of users and their activity.

#### Automatic VACUUM and ANALYZE

Active tables should automatically be `VACUUM`ed and `ANALYZE`d by the PostgreSQL server without needing our direct manual intervention. This will ensure dead tuples are actually removed (which helps reduce disk usage) and indexes are updated (which helps improve query performance). To verify these assumptions, connect to the database and perform the following query:

```psql
SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
    FROM pg_stat_user_tables
    ORDER BY last_autovacuum DESC;
```

Tables that are very small or have no recent activity may not have recent dates in that output.

Running the above query on the prod database on 2022-04-11 indicated that active tables had been auto-vacuumed and auto-analyzed between the last few hours and the last two weeks, and the order of those dates correlated strongly with which tables we would expect to have insert, update, or delete activity.

We do not currently plan to execute `VACUUM FULL` on any database relations in prod. We do not currently believe that there is enough file fragmentation to warrant the potential interruption time that routine `VACUUM FULL`s would incur, and we expect that the normal automatic `VACUUM` will be sufficient for our immediate needs.


### AWS ElastiCache (Redis)

During initial experimentation to synthesize data in a prod-like scale in the stage environment quickly exhausted stage's ElastiCache memory. This happened because the first experiment attempted to synthesize data for all 258 users and their ~150,000 instances simultaneously. The data synthesis process spawns numerous tasks for each user and their instances; so, this first experiment quickly overwhelmed our stage ElastiCache with many hundreds of thousands of messages in short succession. This represented _several orders of magnitude_ more load in terms of task counts than we have ever seen in prod; it would be like compressing the last two years of actual prod traffic into a few minutes' time on less than half the hardware.

Despite the brief problems it caused in stage, that was a valuable learning excercise, and it prompted us to better observe ElastiCache memory usage. We manually removed those synthesized tasks, deleted their incomplete data from the database, and restarted the synthesis process by having the API wait for the first "customer" to complete its lifetime of activity before starting the next.

Outside of the anomalous high memory usage in stage during the initial synthesis, we have never seen memory problems with AWS ElastiCache in stage or prod.

We used `redis-cli` to check various counts and memory usages so we could estimate the effects of increased load. Sampling the _prod_ ElastiCache instance several times across 2022-04-11 and 2022-04-12, we observed _on average_:

- `98450656` bytes (`93.89` MiB) used memory (`INFO MEMORY`).
- `65589` total keys (`KEYS *`).
- `65545` Celery completed task receipt messages (`KEYS celery-task-meta*`) with an average size (`MEMORY USAGE [keyname]`) of `1205` bytes.
- `0` Redis lists (Celery task queues). This is not unusual because Redis lists are deleted when the length is zero, the length is only non-zero when there are pending tasks, and we have enough workers in prod to very quickly read and process pending tasks most of the time.
- `43` Redis sets (Celery task bindings) each with average member count (`SMEMBERS [keyname]`) `2.7` and average size (`MEMORY USAGE [keyname]`) `493` bytes.

At the time of this writing, the current AWS ElastiCache instance size in both stage and prod is `cache.t3.medium` which reportedly includes 3.09 GiB of memory. Since we currently use less than 100 MiB, assuming each new task message is roughly equivalent in size to a task receipt message (which is generally true based on local testing), then this instance size should support at least an order of magnitude more data in tasks before exhausting the limit. Remember that these messages are all short-lived; so, that would be an order of magnitude more _simultaneous_ data load, not cumulative over time.
