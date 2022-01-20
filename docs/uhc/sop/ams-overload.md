# AMS Overload

### Summary

An increase in load on the Account Manager Service (AMS) can cause resource exhaustion that led to oomkills of the AMS pods.  When AMS is down, the majority of OCM operations (such as login, CRUD clusters) fail.

The query below can help identify the user that is causing the requests and provide more information for further debugging / investigation.

### Access required:

- Console access to the AWS account that hosts AMS pods with log access permissions.

### Query

```sql
fields @timestamp, message
| filter @logStream like "uhc-acct-mngr"
| parse message '[accountID=*]' as accid
| filter ispresent(accid)
| stats count(*) as req_count by accid
| sort req_count desc
```
