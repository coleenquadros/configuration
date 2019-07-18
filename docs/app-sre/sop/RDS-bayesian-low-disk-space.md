# RDS bayesian instance has low disk space conditions

## Severity: Critical (prod)

## Impact
- We ever don't want to be in situation when no disk space left for RDS instances.  
- This often results in need of restoring from backup (and immediatelly increasing disk space)

## Summary

Check is in zabbix.  
This SOP describes situation when most of space consumed by logs/traces.

## Access required

- Must have access to bayesian-production project at DSaaS cluster for getting credentials from secrets for accessing to DB.
- Must have ability spin or connect to pods in devtools-sre-tools project at DSaaS-stg cluster or app-sre project in DSaaS one - RDS instance isn't word accessible.

## Steps

- Get credentials from *coreapi-postgres* secret in bayesian-prod project at DSaaS cluster
- `rsh` or spin new pod in devtools-sre-tools project at DSaaS-stg cluster:  
`$ oc rsh postgres-client-rsync-socat-pod-1-hmnq6 bash`
- Connect to instance via psql commandline client:  
`$ psql -h prodbayesian...... -U coreapi -d coreapi`
- And check size of *celery_taskmeta* table. Don't use ~~SELECT COUNT(*) FROM ...`~~, it's very slow and we don't need that precision anyway. Use:    
`coreapi=> SELECT reltuples AS approximate_row_count FROM pg_class WHERE relname = 'celery_taskmeta';`  
Occupied size like 0.4GB per million of records.  
If record count is low - sorry, this SOP isn't for that case, probably need just increase storage or find other space consuming tables that can be trimmed/dropped.
- Stop the workers (contact bayesian team for assistance).
- Drop the *celery_taskmeta* table:  
`coreapi=> DROP TABLE celery_taskmeta;`  
Don't use `DELETE FROM THATTABLE;` - it very slow and all transactions will go to the transaction log, so space consumption will increase, just drop table completely.
- Start the workers, table should be automatically crated, for checking table you may use:  
`coreapi=> \dt`
- Check if alarm goes off and space are reclaimed. It might take some time so __check in 30 minutes or so__.

## Tracking
- This issue: https://jira.coreos.com/browse/APPAI-572 should prevent that specific reason for filling disk space from occurrence in the future. If it still happens - please bump prio/severity of this issue.
