# Creating a user for database diagnostics

For cases where we need to dump a current state of the database, we create an `app-sre-diag` user on the database instance.

This user has read-only permissions on the server, so that we're not exposing ourselves to human (and automation) errors taking down the database.

## Log in to the database using a master account

In RDS, identify the master username of the database and log in to the database using the mysql client. 

In quay, the master user is called `fluxmonkey`. This information was found in the configuration tab of the RDS instance.

todo: Make sure passwords for all master us

## Create the app-sre-diag user

```sql
CREATE USER 'app-sre-diag'@'%' IDENTIFIED BY '<Random 25 letter string>';
```

## Grant the user readonly permissions to diagnostic information

```sql
GRANT SELECT, PROCESS,EXECUTE, REPLICATION CLIENT,SHOW DATABASES,SHOW VIEW ON *.* TO app-sre-diag'@'%';
```

## Store the credentials in vault

- key: DB identifier
- value: password

https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-diag


## Verify that a login with the new user works
