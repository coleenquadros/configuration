
# Summary
-  Pods failing to start up due to liquibase holding the change log lock

You'll see an exception message like the following both in the OpenShift UI, and it is captured in splunk as well.

```
Caused by: liquibase.exception.LockException: Could not acquire change log lock. Currently locked by swatch-tally-service-654b4c797c-fk4tn (10.128.5.181) since 10/12/22, 2:53 PM
```


# Resolution

The `databasechangeloglock` table in the rhsm-subscriptions database must have its record updated so it's no longer marked as locked.

## Confirmation of problem
First, confirm what is going on in the DB using Gabi.  Instructions for using Gabi can be found [on Confluence](https://docs.engineering.redhat.com/display/ENT/Viewing+DB+records+with+Gabi)

```
gabi "select pid,query,state,wait_event from pg_stat_activity where state != 'idle'"
```

|pid  |query                                                                                                                                                                                                                                                                                                                                    |state                        |wait_event|
|-----|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|----------|
|3406 |autovacuum: VACUUM public.tally_measurements                                                                                                                                                                                                                                                                                             |active                       |WALSync   |
|10707|select * from changeloglock                                                                                                                                                                                                                                                                                                              |idle in transaction (aborted)|ClientRead|
|4246 |select pid,query,state,wait_event from pg_stat_activity where state != 'idle'                                                                                                                                                                                                                                                            |active                       |          |
|20924|select account_number from tally_snapshots where id in ('08d371aa-ca6a-4d05-8ab1-2e0e9ae7653f', 3a3a99d6-8c77-4e7e-8e1c-1e2798e6a61e', 495cfa50-c4f1-412e-a8e1-df6c871ccd64', 641ba35d-0b14-499b-b856-42541d7309dd', b860c807-465b-4bdb-9b30-514642b97d67', e7d47872-4a9c-461c-a87b-5689357e5e4a', f8993a89-061f-42a0-abba-6841de12f640')|idle in transaction (aborted)|ClientRead|

There are two options for resolving this
1. Have somebody who has write access to manually remove the lock by executing SQL.
2. Use a utility cron job deployed to the namespace to remove the lock

## Manual Removal

We generally tag the `@crc-infrastructure-team` handle in the `#forum-consoledot` channel in Slack and have them execute the following SQL against the environment we're having problems with.

```sql
delete from databasechangeloglock;
```

- `rhsm-prod` database details can be found in app-interface at [resources/terraform/resources/insights/production/rds/rds-rhsm-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/rds-rhsm-prod.yml)
- `rhsm-stage` database details can be found in app-interface at [resources/terraform/resources/insights/stage/rds/postgres12-rds-1.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/stage/rds/postgres12-rds-1.yml)

## Using CronJob

TBD