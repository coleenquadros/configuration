# The OLM Dance

The OLM "dance" is when you delete the CSV and the Subscription and redeploy with the saas job. It is safe to do so.

## Manual Steps

```sh
oc project hive
oc delete catalogsource <name>
oc delete subscription <name>
oc delete csv <name>
```

Trigger the saas deploy job for Hive. See: [Trigger the saas deploy job for Hive](#trigger-the-saas-deploy-job-for-hive)

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

Trigger the saas deploy job for Hive. See: [Trigger the saas deploy job for Hive](#trigger-the-saas-deploy-job-for-hive)

## Trigger the saas deploy job for Hive

- Find the saas-deploy pipeline for the cluster on which you want to redeploy Hive in visual-app-interface here https://visual-app-interface.devshift.net/services#/services/hive/app.yml
    - It should be called `osd-<env>-<cluster>` (ex: osd-production-hivep01ue1)
- Clicking the pipelinerun in visual-app-interface will take you to the Tekton Pipeline on the CI cluster
- Search for the latest run
- Click the 3-dots menu on the right of the job and click  ̀Rerun`
