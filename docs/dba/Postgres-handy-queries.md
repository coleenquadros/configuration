# Postgres Handy queries

## Login to appropriate database using the following [document](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/dba/connect-to-postgres-mysql-database.md)

### Check long running queries in the database. (update minutes values as needed)
```
SELECT now() - query_start as "runtime", usename, datname, waiting, state, query
  FROM  pg_stat_activity
  WHERE now() - query_start > '2 minutes'::interval
 ORDER BY runtime DESC;
```

### Show active sessions in the database
```
SELECT 
    pid
    ,datname
    ,usename
    ,application_name
    ,client_hostname
    ,client_port
    ,backend_start
    ,query_start
    ,query  
FROM pg_stat_activity
WHERE state <> 'idle'
AND pid<>pg_backend_pid();
```


### Find blocking locks in a database
```
SELECT blocked_locks.pid     AS blocked_pid,
       blocked_activity.usename  AS blocked_user,
       blocking_locks.pid     AS blocking_pid,
       blocking_activity.usename AS blocking_user,
       blocked_activity.query    AS blocked_statement,
       blocking_activity.query   AS current_statement_in_blocking_process
 FROM  pg_catalog.pg_locks         blocked_locks
  JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
  JOIN pg_catalog.pg_locks         blocking_locks
      ON blocking_locks.locktype = blocked_locks.locktype
      AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
      AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
      AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
      AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
      AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
      AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
      AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
      AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
      AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
      AND blocking_locks.pid != blocked_locks.pid
  JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
 WHERE NOT blocked_locks.GRANTED;
```

### Terminate a DB session
```
SELECT pg_terminate_backend(pid)
```

### Check Postgres database variables
```
SHOW <variables_name>;
SHOW ALL; 
``` 

### Explain plan for a query
```
EXPLAIN <query>;
```

### Explain plan and execute a query
```
EXPLAIN ANALYZE <query>;
```

### Describe a table structure
```
\d <tablename>
\d+ <tablename>  -- More info
```

### List all databases
```
\l
```

### List all users 
```
\du
```

### List objects in current database
```
\dt  -- tables
\dt  -- views
\df+ -- procedures or functions
```

### Output a query to a csv file
```
\copy <table or query> to '<local path to the csv file>' CSV HEADER;
```

### Start spooling query results in psql to a file
```
\o <filename>
```

