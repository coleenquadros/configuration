# Getting diagnostic info on Quay's database:

## Prerequisites

- The `app-sre-diag` database user should have been already created with the correct privileges on the database. See: [Diagnostic User](/docs/quay/services/database.md#diagnostic-user)
- All commands should be run in the `diag-container` pod in the `app-sre` namespace. See: [diag-container](/docs/app-sre/sop/diag-container.md)

## Get the database name

The database host url can be obtained from the only `-rds` secret in the `quay` namespace:

```shell
RDS_SECRET=$(oc -n quay get secret quayio-production-rds --no-headers -o custom-columns=":metadata.name" | grep -- -rds$)
$ oc -n quay get secret $RDS_SECRET -o json | jq -r '.data."db.host"|@base64d'
```

Note this output down, we will refer to it as `<db_host>`

Now rsh into the diag-container and connect to the MySQL database:

```shell
$ oc -n app-sre get pods | grep diag-container
$ oc -n app-sre rsh <diag-container-pod>

# now in the diag-container
$ export DB_HOST=<db_host>
```

The password for this user can be found in vault: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-diag

## Run diagnostic commands

The following queries will each run a diagnostic command and add its output to /var/tmp/<diagnosis_type>-<timestamp>.txt

```shell
# in the diag-container
$ export DB_HOST=<db_host>
$ mysql -u app-sre-diag -p -h $DB_HOST -e 'show full processlist;' | tee /var/tmp/processlist-$(date +%Y%m%dT%H%M%S).txt
$ mysql -u app-sre-diag -p -h $DB_HOST -e 'SELECT * from information_schema.innodb_trx' | tee /var/tmp/transactions-$(date +%Y%m%dT%H%M%S).txt
$ mysql -u app-sre-diag -p -h $DB_HOST -e 'SELECT r.trx_id waiting_trx_id, r.trx_mysql_thread_id waiting_thread, b.trx_id blocking_trx_id, b.trx_mysql_thread_id blocking_thread, b.trx_query blocking_query FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;' | tee /var/tmp/transaction_locks-$(date +%Y%m%dT%H%M%S).txt
```

## Save an archive of the reports to your machine

You can use `oc rsync` to copy the generated reports to your machine:

```shell
# In your laptop
oc rsync <diag-container-pod>:/var/tmp/ .
```

Do not skip this step. the diag container doesn't come with a PV and the reports will be deleted on container restarts.
