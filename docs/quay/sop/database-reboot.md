# Rebooting the Quay Database:

## Make sure you ran the diagnostics SOP first

This helps us capture the information around what was causing the DB to lock up

## Actions

- On the AWS RDS console, go to the instance overview page, for example: https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc;is-cluster=false;tab=connectivity.

- Click on Actions -> Reboot

- Check 'Reboot with Failover'

- Let the database instance start again, monitor active connections

- Redeploy quay: `oc patch deployment quay-app -p '{"spec":{"template":{"metadata":{"annotations":{"quay-app-deployment":"ANY_RANDOM_STRING_WILL_TRIGGER_DEPLOYMENT"}}}}}'`
