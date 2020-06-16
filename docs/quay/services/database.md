# Quay.io database

The Quay.io database is an [Amazon RDS](https://aws.amazon.com/rds/) instance deployed in US-East-1 with ID `quayenc-2019-quayvpc`.
It is deployed in master-slave configuration, with automatic failover.

## RDS console

The RDS console can be found at [https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc](https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc)

## Diagnostic User

AppSRE team needs a read-only user to extract diagnostic information from the database.

The read-only user is defined here:
https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-diag

- key: DB identifier
- value: password
- user: `app-sre-diag`

If the user does not exist for a database instance, it must be created and added to the vault secret, following these steps:

- Log into the database using `fluxmonkey` user (the master user) and the password defined in this [vault secret](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/db)
- Create the user:

```sql
/* create user */
CREATE USER 'app-sre-diag'@'%' IDENTIFIED BY '<Random 25 letter string>';
/* grant read-only privileges */
GRANT SELECT, PROCESS,EXECUTE, REPLICATION CLIENT,SHOW DATABASES,SHOW VIEW ON *.* TO app-sre-diag'@'%';
```

- Add it to vault: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-diag

## Encountered Issues

- [Unusually high CPU usage on database](../issues/high-database-cpu.md)
