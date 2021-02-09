# Handy MySQL queries

### Login to appropriate database using the following [document](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/dba/connect-to-postgres-mysql-database.md)

### Check Record locks MySQL
```
SELECT r.trx_id waiting_trx_id, r.trx_mysql_thread_id waiting_thread,b.trx_id blocking_trx_id, b.trx_mysql_thread_id blocking_thread, 
b.trx_query blocking_query FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id 
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```
### Analysing SLOW Queries in MySQL
To analyze the slow query log execute the below command
```
mysqldumpslow /var/lib/mysqllog_slow_queries.log
mysqldumpslow --help  will give all the options available for dumping the slow queries
```

### Output a query in MySQL to a csv file
```
mysql> select <column_name> from <table_name> INTO OUTFILE '/tmp/csvoutput.csv' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
```

### Explain Plan for SQL Statements
```
mysql> EXPLAIN EXTENDED select <column_name> from <table_name> where <column_name>=4444\G
```

### Database Profiling for SQL statements
To get how a select sql is performing we need to enable the profile like 
```
mysql> use <database_name>
mysql> set profiling=1;
mysql> select * from <table_name> where <column_name>='asdfas';   /// the query you need to tune
mysql> show profile for query 1;
```
The above stats show where exactly the query is taking long time in seconds

### Show Database initialization Parameters
```
mysql> show variables like '%<database_parameter>%';
mysql> show variables;   ---- Will list all the DB parameters
```

### Updating a DB parameter at the DB level (temporary DB parameter change)
```
mysql> set global <parameter_name>=<parameter_value>;
```
The above change will not persist after restart of the database. 
Applicable for only permitted parameters only.

### Getting count of connections for each client
```
mysql>select count(*),SUBSTRING_INDEX(Host,':',1) from information_schema.PROCESSLIST group by 2;
```

### Miscellenious commands
```
mysql> SHOW PROCESSLIST;      --- Shows all the DB processes from different hosts
mysql> KILL <pid>;            --- To kill a specific db session for the process id displayed by show processlist command.
mysql> SHOW DATABASES;        --- Displays all databases in the mysql server
mysql> USE <database name>;   --- Will change to start using that database.
mysql> SHOW TABLES;           --- Will display list of tables in the database (used mostly in continuation with USE <database name>;
mysql> show fields from <table_name>; --display table structure
mysql> describe <table_name>;   --- display table structure 
mysql> show keys from <table_name>;   --display the constraint columns/details
```

