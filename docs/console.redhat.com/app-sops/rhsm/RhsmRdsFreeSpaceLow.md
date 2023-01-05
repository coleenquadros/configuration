# RhsmRdsFreeSpaceLow
Severity: Medium

## Impact
The service could go down due to lack of database storage and then customers would be unable to access their subscription usage and capacity information. If the issue persists for too long the daily tally may not be able to complete resulting in missing data.

## Summary
This alert fires when the RDS database is predicted to run out of space in 4 days.

## Access required
AWS accoount access is needed to increase the database capacity.

## Steps
-  Bump the RDS allocated_storage size by 20% by following https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-rds-vertical-scale.md 

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
