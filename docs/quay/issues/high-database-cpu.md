# Debugging high CPU usage on the database

## The Queue table is backed up

### Check the queue depth

Check the Queue Depths in the table:

```sql
SELECT count(*) from queueitem;
```
### Check builds

Query the Quay database to determine the what namespaces have the most builds:

```sql
SELECT
    COUNT(repositorybuild.id), ns.username, ns.email
FROM
    repositorybuild
        INNER JOIN
    repository ON repository.id = repositorybuild.repository_id
        INNER JOIN
    user AS ns ON ns.id = repository.namespace_user_id
WHERE
    repositorybuild.phase = 'waiting'
GROUP BY ns.id
HAVING COUNT(repositorybuild.id) > 5
ORDER BY COUNT(repositorybuild.id) DESC;
```

#### If there is a namespace abusing the build system

Disable the namespace from an instance of Quay:

```sh
$ docker exec quay venv/bin/python -m util.disableabuser NAMESPACE_NAME dockerfilebuild
```

### If the queue depth is still too high (greater than 100)

Delete all expired items from Quay's queue:

```sql
DELETE FROM queueitem WHERE retries_remaning=0 AND available=1;
```
