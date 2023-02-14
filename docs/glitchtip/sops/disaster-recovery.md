# Disaster recovery

All the application data is stored in the [Postgres database hosted on AWS](data/services/glitchtip/namespaces/glitchtip-production.yaml).

To recover the service after a data loss,
  1. use the database service (e.g. RDS) data recovery mechanism and
  2. re-start the service.

Instructions on recovering an RDS instance from a snapshot are available here: https://gitlab.cee.redhat.com/service/app-interface#create-rds-database-from-snapshot.

## Data loss impact

In case of a complete data loss, all the historical data (events, alerts, and issues) will be lost.

All metadata (organizations, projects, users, etc.) will be recreated by `qontract-reconcile`, and all API users will be restored from Vault during the startup of `glitchtip-web`.
