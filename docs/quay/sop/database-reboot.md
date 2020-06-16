# Rebooting the Quay Database:

## Make sure you ran the diagnostics SOP first

This helps us capture the information around what was causing the DB to lock up

## Scale down the quay application pods to 0


```
# note down the number of current replicas
DESIRED_REPLICAS=$(oc get deployment quay-app -o json | jq -r .spec.replicas)
echo "DESIRED_REPLICAS: $DESIRED_REPLICAS"

# scale down to 0 replicas
oc scale -n quay deployment quay-app --replicas=0
```

## Reboot the database

- On the AWS RDS console, go to the instance overview page, for example: https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=quayenc-2019-quayvpc;is-cluster=false;tab=connectivity

- Click on Actions -> Reboot

- Check 'Reboot with Failover' if available

- Let the database instance start again, monitor active connections

- Scale back to the desired number of replicas: `oc scale -n quay deployment quay-app --replicas=$DESIRED_REPLICAS`. `$DESIRED_REPLICAS` should have been obtained in the from the previous step.
