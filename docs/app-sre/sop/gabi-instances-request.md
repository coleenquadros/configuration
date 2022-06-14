# Gabi Instances

## Table of contents

* [Introduction](#introduction)
* [Request Gabi Instances](#request-gabi-instances)
* [Deploy Gabi Instances](#deploy-gabi-instances)
* [Access Gabi Instances](#access-gabi-instances)


## Introduction

In order to provide generic db access for tenant‘s service, we provide [gabi](https://github.com/app-sre/gabi) to run SQL queries on protected databases. Currently, gabi supports MySQL and PostgreSQL. 

For **InProgress or OnBoarded apps, tenants will only be allowed to access read-replicas (for both stage and prod)**. A read-replica will need to be created if one doesn't already exist, and that this will increase costs so **management approval will be required**.

For best-effort apps tenant can access to actual DBs (stage and prod)

Gabi will be deployed in the namespaces with the RDS resource definition.

## Request Gabi Instances

Tenant will need to commit to the app-interface an YAML file with the following content:

```yaml
$schema: /app-sre/gabi-instance-1.yml

labels:
  service: gabi

name: <gabi instance name>
description: |
 I would like to be able to get db access for <database name>
 I acknowledge there is no sensitive data or there is sensitive data, but agrees to have a specific engineer accessing it

signoffManagers:
- $ref: <user-1.yml who can signoff as description>
...
users:
- $ref: <user-1.yml who need to access database>
...

instances:
- account: <RDS resource account defined in the namespace>
  identifier: <RDS resource identifier defined in the namespace (this should be a read-replica for InProgress/OnBoarded apps)>
  namespace: 
    $ref: /services/<service>/namespaces/<namespace>.yml
...

expirationDate: <YYYY-MM-DD>
```

[example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/gabi/gabi-instances/gabi-dashdotdb.yml)


One gabi instance can include multiple namesapces for different environment. As a result, a configmap with a list of authorized users will be applied in these namespaces by [integration](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/gabi_authorized_users.py). The configmap name will be as same as gabi instance name.

The maximum expiration date of gabi instance shall not exceed 90 days form the day request, and need to renew when expiration date approach. Otherwise, the configmap will be emptied and all users will lost access to gabi endpoint, resulting in an `Unauthorized` message.

## Deploy Gabi Instances

### Step 1: Splunk Access

Gabi uses splunk for audit logs, so it needs a [splunk-creds](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/shared-resources/splunk-creds.yml). 

Tenant need to add it to target namespaces as a shared resource with the following content:

```yaml
sharedResources:
- $ref: /services/app-sre/shared-resources/splunk-creds.yml
```

### Step 2: SaaS File

Gabi will be deployed via [saas file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/gabi/cicd/saas-gabi.yaml).

Tenant must add new target namespaces with the following content:

```yaml
  - namespace:
      $ref: /services/<service>/namespaces/<namespace>.yml
    ref: <commit hash from https://github.com/app-sre/gabi, copy from other targets>
    parameters:
      HOST: <endpoint of gabi, suggest using gabi_instance_name.cluster_name.cluster_id.p1.openshiftapps.com>
      NAMESPACE: <target namespace name>
      AWS_RDS_SECRET_NAME: <secret of rds creds, >
      USERS_CONFIGMAP_NAME: <as the same as gabi instance name>
      DB_DRIVER: <pgx or mysql, default is pgx (postgres)>
```

### Step 3: Cluster-Scoped Gabi Namespace

Additionally, ensure a gabi-cluster-resource namespace exists for the cluster(s) your namespace(s) you're deploying in [this directory](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/gabi/namespaces). 

If such a file already exists, you can move to the next step. Otherwise, if such a file is missing for any cluster you're deploying Gabi to, please create it! 

To create such a file, copy one of the existing file (e.g. [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/gabi/namespaces/gabi-app-sre-stage-01-cluster-scope.yml)), and rename the file and replace instances of the cluster-name in the file content.

### Step 4: Cluster-Scoped Resources

Navigate [here](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/app-sre/gabi).

Check that files exist for each cluster you are deploying gabi to.

If a file is missing for your cluster, please create it! You can copy+paste the following content into it:

```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gabi-openshift-oauth-delegate
subjects:
  - kind: ServiceAccount
    name: gabi
    namespace: <YOUR NAMESPACE HERE>
roleRef:
  kind: ClusterRole
  name: gabi-openshift-oauth-delegate
  apiGroup: rbac.authorization.k8s.io
```

If files for your cluster(s) already exist, add a new list item to the `subjects:` array with the following content:
```
  - kind: ServiceAccount
    name: gabi
    namespace: <YOUR NAMESPACE HERE>
```

### Step 5: Update OpenShift-Config

For each cluster you're deploying Gabi to, you will want to ensure that in each cluster's `openshift-config` namespace, that it is managing `dedicated-readers` and `self-provisioners` ([Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/82de8d62d081e98e1b5816a97f232bf050216b82/data/openshift/app-sre-stage-01/namespaces/openshift-config.yaml#L36-39)). If it doesn't already exist there, add the following YAML array item to resource `managedResourceNames`:
```
  resourceNames:
  - dedicated-readers
  - self-provisioners
```

## Access Gabi Instances

Once gabi is deployed, authorized users can use their person cluster token to access gabi enpoint. 

1. Login into the cluster console
2. Make sure user have view access to the namespace that contains the gabi instance.
3. Get cluster api token from cluster console
4. Check gabi access via `curl -H 'Authorization: Bearer <api_token>' https://<gabi_endpoint>/healthcheck`
5. Query rds via `curl -H 'Authorization: Bearer <api_token>' https://<gabi_endpoint>/query -d '{"query": "<query_string>"}' -s | jq`
