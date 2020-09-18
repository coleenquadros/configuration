# The OLM Dance

The OLM "dance" is when you delete the CSV and the Subscription and redeploy with the saas job. It is safe to do so.

## Manual Steps

```sh
oc project hive
oc delete catalogsource <name>
oc delete subscription <name>
oc delete csv <name>
```

Trigger the saas deploy job for Hive https://ci.int.devshift.net/view/hive/job/openshift-saas-deploy-saas-hive-osd-production/

## Using Script

Run the [reset-olm.sh](reset-olm.sh) script from your machine.

### Dry Run

```sh
./reset-olm.sh -n hive
```

### Do the Dance

```sh
./reset-olm.sh -n hive -d
```

Example Output:

```sh
Deteting subscription: hive
subscription.operators.coreos.com "hive" deleted
Deteting subscription: hive-catalog
catalogsource.operators.coreos.com "hive-catalog" deleted
Deteting subscription: hive
operatorgroup.operators.coreos.com "hive-og" deleted
Deteting CSV: hive-operator.v0.1.2202-sha86cd1c9
clusterserviceversion.operators.coreos.com "hive-operator.v0.1.2202-sha86cd1c9" deleted
Deteting CSV: hive-operator.v0.1.2257-sha0f9c2b4
clusterserviceversion.operators.coreos.com "hive-operator.v0.1.2257-sha0f9c2b4" deleted
Deteting CSV: hive-operator.v0.1.2274-sha0e29757
clusterserviceversion.operators.coreos.com "hive-operator.v0.1.2274-sha0e29757" deleted
```


Trigger the saas deploy job for Hive https://ci.int.devshift.net/view/hive/job/openshift-saas-deploy-saas-hive-osd-production/
