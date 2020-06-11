# Getting diagnostic info on Quay's database:

## Prerequisites

- The `app-sre-diag` user should be created with the correct privileges on the database. See: docs/app-sre/sop/app-sre-diag-user.md
- Access to the app-sre namespace on the quay cluster to be able to rsh into the pod and use the mysql client

## Get the database name

The database URI can be found in the `quay-config-secret` mounted in the quay pods. Make sure you use exactly the one being mounted in the pod!

You need to look in the secret field called `config.yaml` which should have a key `DB_URI`

It may be easier to also look at the `-rds` secrets in the namespace, for example the `quayenc-2019-quayvpc-rds` will have the required `db.host`

The format of the DB URI is `mysql+pymysql://quayio:<encoded_password>@<dbname>/quay`

Copy the DB name and export it into a variable for later use. For example:

```shell
export DB_HOST="quayenc-2019-quayvpc.cb0vumcygprn.us-east-1.rds.amazonaws.com"
```

## Connecting to the Database server

```shell
mysql -u app-sre-diag -p -h $DB_HOST
```

The password for this user across database instances can be found in vault: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-diag

## Run diagnostic commands

The following queries will each run a diagnostic command and add it's output to /var/tmp/<diagnosis_type>-<timestamp>.txt

```shell
mysql -u app-sre-diag -p -h $DB_HOST -e 'show full processlist;' | tee /var/tmp/processlist-$(date +%Y%m%dT%H%M%S).txt

mysql -u app-sre-diag -p -h quayenc-2019-quayvpc.cb0vumcygprn.us-east-1.rds.amazonaws.com -e 'SELECT * from information_schema.innodb_trx' | tee /var/tmp/transactions-$(date +%Y%m%dT%H%M%S).txt

mysql -u app-sre-diag -p -h quayenc-2019-quayvpc.cb0vumcygprn.us-east-1.rds.amazonaws.com -e 'SELECT r.trx_id waiting_trx_id, r.trx_mysql_thread_id waiting_thread, b.trx_id blocking_trx_id, b.trx_mysql_thread_id blocking_thread, b.trx_query blocking_query FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;' | tee /var/tmp/transaction_locks-$(date +%Y%m%dT%H%M%S).txt
```

## Save an archive of the reports to your machine

You can use `oc rsync` to copy the generated reports to your machine:

```
oc rsync diag-container-1-pm9cz:/var/tmp/ .
```

Do not skip this step. the diag container doesn't come with a PV and the reports will be deleted on container restarts.
