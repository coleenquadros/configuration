# PostgreSQL Execute SQL Scripts

- [PostgreSQL Execute SQL Scripts](#postgresql-execute-sql-scripts)
  - [WARNING](#warning)
  - [Container Image](#container-image)
  - [SQL Scripts in ConfigMap](#sql-scripts-in-configmap)
    - [ConfigMap Example](#configmap-example)
    - [OpenShift Job & Template](#openshift-job--template)
      - [Job & Template Example](#job--template-example)
  - [Deploying the Job](#deploying-the-job)
  - [Re-Trigger Job](#re-trigger-job)

This document shows you how to run SQL scripts against app-interface managed PostgreSQL RDS instance.

## DISCLAIMER

**The SQL scripts will be executed by a user that has admin privileges to the database. Bad script can result in data loss or database destruction. Any issues resulting from using this tool can not be handled by the App SRE team.**

For alternate approaches, please consult the [db-migrations](docs/dba/db-migrations.md) section.

## Container Image

The container image to use for running your SQL scripts is [`quay.io/cloudservices/pg-script-runner`](https://quay.io/repository/cloudservices/pg-script-runner). You should use the tag that `latest` points to. Avoid using the `latest` itself as the tag for the container image.

## SQL Scripts in ConfigMap

We will provide SQL scripts to the `pg-script-runner` container by mounting a `ConfigMap` as a `volume`. Your ConfigMap may contain more than one SQL scripts. You can order the execution of these scripts by following the naming convention `NN-script-description.sql` where `NN` is the order of script execution starting with `00` which will be the first script to be executed.

### ConfigMap Example

Here's an example of the ConfigMap that contains multiple SQL scripts with defined execution order:

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sql-scripts
data:
  00-example-script.sql: |
    SELECT  * FROM  (values (1)) AS v (id);
  01-example-script.sql: |
    SELECT  * FROM  (values (1)) AS v (id);
```

### OpenShift Job & Template

The SQL scripts will be executed by a Kubernetes `Job`. The Job and Template must do the following:

1. Execute only once.
2. If the Job fails, it should not retry or re-run. App owners will decide what to do when a Job fails.
3. Each execution should create a unique job. This is achieved by providing a unique `JOB_NAME_SUFFIX` to the Job.
4. Read the database credentials from Secret used by the application and pass them as environment variables to the Job. Set `DB_SECRET` to the name of the Secret that contains database credentials.
5. Set the max duration for Job execution. The default is set to `600` seconds.
6. Set `IMAGE_TAG` to `latest` or the tag `latest` points.
7. Set `restartPolicy` to `Never`.
8. Provide the ConfigMap name to the Job by setting `SQL_SCRIPTS_CONFIGMAP_NAME` parameter.

Note: You can ignore the parameter `PGVERSION`. It does not need to be set for now.

#### Job & Template Example

```yaml
---
apiVersion: v1
kind: Template
metadata:
  name: pg-script-runner
parameters:
- name: SQL_SCRIPTS_CONFIGMAP_NAME
  value: "sql-scripts"
  required: true
- name: JOB_NAME_SUFFIX
  value: ""
  required: true
- name: DB_SECRET
  value: ""
  required: true
- name: PGCONNECT_TIMEOUT
  value: "30"
  required: true
- name: PGSSLMODE
  value: "require"
  required: true
- name: PG_IMAGE
  value: "quay.io/cloudservices/pg-script-runner"
  required: true
- name: PG_IMAGE_TAG
  value: "latest"
  required: true
- name: IMAGE_TAG
  value: "NOT-USED"
- name: PGVERSION
  value: ""
- name: ACTIVE_DEADLINE_SECONDS
  value: "600"
  required: true
objects:
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: sql-scripts
  data:
    00-example-script.sql: |
      SELECT  * FROM  (values (1)) AS v (id);
    01-example-script.sql: |
      SELECT  * FROM  (values (1)) AS v (id);
- apiVersion: batch/v1
  kind: Job
  metadata:
    name: pg-script-runner-${JOB_NAME_SUFFIX}
  spec:
    template:
      metadata:
        labels:
          app: pg-script-runner-${JOB_NAME_SUFFIX}
      spec:
        activeDeadlineSeconds: ${{ACTIVE_DEADLINE_SECONDS}}
        backoffLimit: 1
        completions: 1
        parallelism: 1
        restartPolicy: Never
        volumes:
        - name: pg-scripts-d
          configMap:
            defaultMode: 420
            name: ${{SQL_SCRIPTS_CONFIGMAP_NAME}}
        containers:
        - name: pg-script-runner-${JOB_NAME_SUFFIX}
          image: ${PG_IMAGE}:${PG_IMAGE_TAG}
          volumeMounts:
          - name: pg-scripts-d
            mountPath: /opt/app-root/pg-script-runner/pg-scripts.d
          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 100m
              memory: 128Mi
          env:
          - name: PGHOST
            valueFrom:
              secretKeyRef:
                name: ${{DB_SECRET}}
                key: "db.host"
          - name: PGPORT
            valueFrom:
              secretKeyRef:
                name: ${{DB_SECRET}}
                key: "db.port"
          - name: PGDATABASE
            valueFrom:
              secretKeyRef:
                name: ${{DB_SECRET}}
                key: "db.name"
          - name: PGUSER
            valueFrom:
              secretKeyRef:
                name: ${{DB_SECRET}}
                key: "db.user"
          - name: PGPASSWORD
            valueFrom:
              secretKeyRef:
                name: ${{DB_SECRET}}
                key: "db.password"
          - name: TARGET_DATABASE
            valueFrom:
              secretKeyRef:
                name: ${{DB_SECRET}}
                key: "db.name"
          - name: PGVERSION
            value: ${PGVERSION}
          - name: PGSSLMODE
            value: ${{PGSSLMODE}}
          - name: PGCONNECT_TIMEOUT
            value: ${PGCONNECT_TIMEOUT}
```

## Deploying the Job

The Job will be deployed to your OpenShift project by adding it to your application's SaaS file. `ref` should be set to the commit that has the version of ConfigMap & OpenShift Template you want executed.

```yaml
- name: YOUR-APP-NAME-pg-script-runner
  path: /openshift.yml
  url: https://gitlab.cee.redhat.com/YOUR/REPO
  targets:
  # staging
  - namespace:
      $ref: /services/insights/<DIR>/namespaces/<FILE-NAME>.yml
    ref: <REF> # NEVER SET TO MASTER EVEN FOR STAGING
    parameters:
      PG_IMAGE_TAG: "latest"
      DB_SECRET: "MY-DB-SECRET"
      ACTIVE_DEADLINE_SECONDS: "600"
      JOB_NAME_SUFFIX: "UNIQUE_SUFFIX_FOR_JOB_NAME"
  # production
  - namespace:
      $ref: /services/insights/<DIR>/namespaces/<FILE-NAME>.yml
    ref: <REF> # NEVER SET TO MASTER EVEN FOR STAGING
    parameters:
      PG_IMAGE_TAG: "latest"
      DB_SECRET: "MY-DB-SECRET"
      ACTIVE_DEADLINE_SECONDS: "600"
      JOB_NAME_SUFFIX: "UNIQUE_SUFFIX_FOR_JOB_NAME"
```

## Re-Trigger Job

At times you may want to re-run a Job without changing the OpenShift template. You can do this setting the `JOB_NAME_SUFFIX` to a new unique value.
