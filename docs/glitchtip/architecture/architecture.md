# Glitchtip architecture

## Service Description

Glitchtip is an open-source error-tracking software (a fork of Sentry) and is compatible with Sentry client SDKs. It makes monitoring software easy. Track errors, monitor performance, and check site uptime all in one place.

The production environment is available via https://glitchtip.devshift.net, and the staging environment (AppSRE only) is reachable via https://glitchtip.stage.devshift.net.

## Components

### glitchtip-web

It consists of the web UI (`glitchtip-frontend`) and the Django backend (`glitchtip-backend`). If it's unavailable, the users won't be able to access the web UI and can't send any error events.

### glitchtip-worker

The workers are background tasks ([celery](https://docs.celeryq.dev/en/stable/index.html) jobs) scheduled via `glitchtip-web` and `glitchtip-beat`.

Some important background tasks are:
* **process event alerts**: Process event alerts and send notifications for issues.
* **cleanup old events**: Delete old events and issues from the database.
* **update search indexes**: Update the search indexes for issues and events.
* **project statistics**: Update the project statistics.


### glitchtip-beat

The periodic tasks scheduler; it kicks off tasks at regular intervals that are then executed by available `glitchtip-worker` nodes.

## Routes

The glichtip web application is available via https://glitchtip.devshift.net.

## Dependencies

### Vault

The `glitchtip-web` deployment fetches, via init-container, all required API user credentials from Vault and creates and updates the Django users accordingly.
If Vault is unavailable during the start of `glitchtip-web`, the init-container will fail, and the pod won't get ready.

### RDS

Glitchtip uses a Postgres database hosted on AWS. If the database is unavailable, this will be a major outage for the application. As soon as the database is available again, the application will recover by itself.

### ElasticCache (Redis)

Glitchtip uses ElasticCache (Redis) for caching. If the cache is unavailable, the application will have an outage, but will recover as soon as the cache is available again.

## Service Diagram

![Glitchtip](images/architecture.png)


## Application Success Criteria

Glitchtip will become the successor of Sentry for the AppSRE team and will be used for monitoring
and error tracking of several Red Hat applications.

## State

* Postgres database: Store events, issues, and other data. If unavailable, the application will have a major outage.
* ElasticCache (Redis): Cache; if unavailable, the application will have an outage.

## Load Testing

See [Load Testing](../sops/load-testing.md) for more information.


## Capacity

| Component            | CPU (request/limit) | Memory (request/limit) | Storage |
| -------------------- | ------------------- | ---------------------- | ------- |
| glitchtip-web        | 3x 500m/1           | 3x 500Mi/500Mi         | -       |
| glitchtip-worker     | 3x 500m/1           | 3x 1.2Gi/1.2Gi         | -       |
| glitchtip-beat       | 1x 100m/500m        | 1x 700Mi/700Mi         | -       |
| RDS                  | db.m6g.large        | db.m6g.large           | 80Gi    |
| ElasticCache (Redis) | cache.t3.small      | cache.t3.small         | -       |


I don't expect significant changes in the capacity requirements in the next 12 months.
