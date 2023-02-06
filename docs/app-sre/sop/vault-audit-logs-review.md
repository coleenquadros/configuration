# Reviewing Vault Audit Logs
Each Vault instance managed by AppSRE includes a [file type audit device](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/prod/audit-backends/file-audit.yml). This file is [processed by fluentd](https://gitlab.cee.redhat.com/service/vault-devshift-net/-/blob/master/openshift-vault.yaml#L181) to export all logs to s3 (dedicated bucket per instance).

Due to the substantial volume of logs that vault instances generate, [Amazon Athena](https://docs.aws.amazon.com/athena/index.html) is utilized to query the data within s3.

Note: the s3 buckets and supporting Athena resources reside within us-east-1 of the [app-sre aws account](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/account.yml).


## Using Athena
By default, all AppSRE members should have unrestricted access within Athena. The `app-sre` workgroup should be utilized for executing queries.


### Pricing
Athena pricing is straightforward for our use case at [$5.00](https://aws.amazon.com/athena/pricing/) per terabyte scanned within queries. There is no charge for DDL (Data Definition Language) statements such as table creation or deletion.

However, due to the volume of audit logs, scanning of > 1TB is easily achievable with queries that do not specify a partition within the `where` clause. The proceeding sections on partitioning elaborate on creating and utilizing partitions.

There should rarely, if ever, be a need to perform basic queries such as:  
`select * from app_sre_vault_audit_logs_prod` 


### Tables
A dedicated table exists for each Vault instance:
* app_sre_vault_audit_logs_stage
* app_sre_vault_audit_logs_ci-ext
* app_sre_vault_audit_logs_prod

Properties of each table can be inspected by navigating to:  
`Administration > Data sources > AwsDataCatalog > app_sre_vault`  
or by reviewing the `create_table` saved queries within `app-sre` workgroup.


### Saved Queries
The proceeding sections make frequent reference to [Saved queries](https://docs.aws.amazon.com/athena/latest/ug/saved-queries.html). The saved queries within the `app-sre` workgroup facilitate structuring of data and obtaining information.

To utilize saved queries, navigate to `Query editor > Saved queries tab`. 

Note: it is okay to alter and execute a saved query. Do not save altered saved queries. If you develop a useful query that is not currently present, please save it as a new query. Additionally, saved queries are tracked within the [infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/terraform/app-sre/athena).


### Partitions
[Partitions](https://docs.aws.amazon.com/athena/latest/ug/partitions.html) greatly reduce the execution time and amount of data scanned when executing a query.

#### Default Partitions
For each table, there is a saved query that can be altered to create a new partition.

The default tables include a `partition by` for year, month, and day. This means that creation of new partitions and execution of queries against these tables must specify all three parameters. 

To create a new partition for a table, open the corresponding saved query (ex: `create_vault_audit_logs_prod_partition`) and adjust the parameters within `PARTITION` as well as the `LOCATION` path.

Example to create new partition for Feb 1, 2023 on prod table:
```
    ALTER TABLE app_sre_vault_audit_logs_prod ADD
    PARTITION (year = '2023', month = '02', day = '01') 
    LOCATION 's3://app-sre-vault-audit-prod/audit/2023/02/01/';
```

**NOTE:** due to naming of directories within s3, it is important to specify `01` and not `1` within queries for single digit months/days.

#### Creating Broader Partitions
As noted above, default partitions require specification of year, month, and day. And although creating new day partitions may suffice for a window of 2-3 days, this approach does not scale well.

When the need arises to broaden the scope of partitions, the suggested approach is to create a new table with an altered `PARTITION BY` clause.  

For example, to query production logs with only year and month granularity, the following steps should be taken:
1. open the `create_vault_audit_logs_prod_partition` saved query
2. perform the following: 
    * edit the table name
    * remove the `day` attribute within `PARTITION BY` clause
3. run new query (do not overwrite saved query)
4. open the `create_vault_audit_logs_prod_partition` saved query
5. perform the following:
    * edit the table name
    * remove `day` attribute from `PARTITION`
    * remove `day` portion of path within `LOCATION`
6. run the query (do not overwrite saved query)


### Common Select Queries
Several `select` saved queries have been provided to address common use cases. These also serve as a base for developing more elaborate custom queries.

#### get_all_operations_at_path  
Lists operations performed at specified path. Groups by operation and path. Specified path can be "wide" like the example `app-sre/%` or specific (`app-sre/creds/vault-manager`)

#### get_all_secret_modifications_by_users
Lists all `update` and `delete` operations performed by any user across all secret mounts. 
* Approles are ignored to reduce noise
* `AND request.path LIKE 'app-sre/%'` can be included to limit scope

#### get_secret_paths_oidc_user_accessed
Lists when specified user accessed specific secret paths. 
* `sys/*` and `auth/*` are internal Vault paths that are ignored to reduce noise.
