# cloudigrade disaster recovery

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch.

See also [Data Continuity and Disaster Recovery](https://github.com/cloudigrade/cloudigrade/blob/master/docs/architecture.md#data-continuity-and-disaster-recovery) in [cloudigrade Architecture Document](https://github.com/cloudigrade/cloudigrade/blob/master/docs/architecture.md).

## Summary

Follow these steps to recover from disaster.

## Steps

-  If secrets have been lost, reach out to the engineering team to reissue them.
    -  cloudigrade pods will fail to start if secrets are missing.
    -  cloudigrade uses `vault-secret` providers much like other services.
    -  See the `openshiftResources` definitions in [stage-cloudigrade-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/stage-cloudigrade-stage.yml) and [cloudigrade-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/cloudigrade-prod.yml).
-  Otherwise, no cloudigrade specific steps need to be taken.
    - Deployments are fully configured in app-interface.
    - DB migrations automatically run during deployment.
    - AWS resources (buckets, queues, etc.) are automatically created and configured during deployment.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
