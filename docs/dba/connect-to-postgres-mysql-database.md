- [Connect to MySQL or PostgreSQL Database](#connect-to-mysql-or-postgresql-database)
  - [Prerequisites](#prerequisites)
  - [Deploy Diag Container](#deploy-diag-container)
  - [Connect to MySQL Database](#connect-to-mysql-database)
  - [Connect to PostgreSQL Database](#connect-to-postgresql-database)
    - [Known Issues](#known-issues)
  - [Using Other Tools](#using-other-tools)

# Connect to MySQL or PostgreSQL Database

## Prerequisites

1. Access to the OpenShift Cluster with ability to `exec` into containers.
2. Secret with database credentials.
3. `oc` client installed on your system.

## Deploy Diag Container

1. Clone the [diag container](https://github.com/app-sre/diag-container) repository locally on your system.
2. Get OpenShift login token.
3. Switch to the OpenShift namespace with command `oc project <project-name>`.
4. Process the OpenShift template to deploy the diag container using the command `oc process --local -f openshift.yml -p POSTGRES_DB_SECRET_NAME="<db-secret-name" | oc create -f -`.
   1. `POSTGRES_DB_SECRET_NAME` can be skipped if you are connecting to MySQL.
5. List all the pods using command `oc get pods` and you should see pod running with name starting with `diag-container`.

## Connect to MySQL Database

1. `Exec` into the pods using command `oc exec -it <diag-container-pod-name> -- /bin/bash`.
2. Connect to MySQL database using the command `mysql -h HOSTNAME -u USERNAME -p`. You will provide database password when prompted.
3. To query database, select the database by running the `use <database-name>` command on the `mysql` prompt.

## Connect to PostgreSQL Database

`Exec` into the pods using command `oc exec -it <diag-container-pod-name> -- psql`. Because the template provides all connection parameters to the diag container in the environment, the above exec command will establish connection directly to PostgreSQL database.

### Known Issues

1. This method does not work when connecting to read only RDS instance because username and password are not available in read only RDS instance secret.

## Using Other Tools

1. `Exec` into the pods using command `oc exec -it <diag-container-pod-name> -- /bin/bash` to get shell. You can then execute any of the other tools that are packaged in the diag container.
