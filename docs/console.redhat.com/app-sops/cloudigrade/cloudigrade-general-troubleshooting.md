# cloudigrade general troubleshooting

## Summary

If cloudigrade deployments are misbehaving, follow this document for general troubleshooting guidance.

cloudigrade and postigrade deployments are controlled by the Clowder operator. If you are not familiar with Clowder, please reference its documentation and SOPs. The cloudigrade team is not responsible for Clowder's general operation and maintenance. See also:

- https://github.com/RedHatInsights/clowder/
- https://redhatinsights.github.io/clowder/clowder/dev/sop.html
- https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/console.redhat.com/app-sops/clowder

## Verify runtime service dependencies

If cloudigrade is returning an unusually high rate of failure responses, verify first that the following runtime service dependencies are operating normally:

1. **3scale**: cloudigrade-api pods expect most incoming HTTP requests to have HTTP headers that include the customer's identity. These headers are provided by the managed 3scale gateway. See also: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/console.redhat.com/app-sops/3scale
2. **Kafka**: cloudigrade-worker and cloudigrade-listener pods use the managed Kafka instance to read from and write to sources-api. See also: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/console.redhat.com/app-sops/kafka
3. **sources-api**: cloudigrade-worker pods execute HTTP requests to sources-api. See also: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/console.redhat.com/app-sops/sources
4. **AWS RDS**: All cloudigrade deployments use postigrade for their database connections, and postigrade proxies those connections to the SRE-managed AWS RDS instance. See also: https://status.aws.amazon.com/
5. **AWS CloudWatch**: All cloudigrade deployments send logs to the Insights-managed AWS account. See also: https://status.aws.amazon.com/
6. **AWS EC2, CloudTrail, SQS, S3, STS, IAM**: cloudigrade-api and cloudigrade-worker pods perform many operations in AWS. See also: https://status.aws.amazon.com/
7. **Azure Compute, Management and governance**: cloudigrade-worker pods perform operations in Azure. See also: https://status.azure.com/

cloudigrade and postigrade do not rely on any other internal console-dot services during normal operation.

## Redeploy by changing an app-interface parameter

cloudigrade and postigrade deployments should update and redeploy upon changing one of their `parameter` configs in [`deploy-clowder.yml`](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/cicd/deploy-clowder.yml). To trigger a fresh deployment of cloudigrade, you could commit, push, and merge a change that updates the value of `OSD_REDEPLOY_TRIGGER` (preferably to a string containing the current date and time) for the relevant namespace. `OSD_REDEPLOY_TRIGGER` is not used by anything else in cloudigrade's code; it only exists as a convenient mechanism to trigger a redeploy manually through app-interface.

```yml
  - namespace:
      $ref: /services/insights/cloudigrade/namespaces/cloudigrade-prod.yml
    parameters:
      OSD_REDEPLOY_TRIGGER: '202206011010'
```

## Redeploy by `oc delete`

To force a cloudigrade or postigrade deployment to completely redeploy, you could simply delete that deployment. Upon detecting that it is missing, the Clowder operator should quickly recreate the deployment using the current configuration. For example:

```
$ oc get deployment/cloudigrade-api
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
cloudigrade-api   1/1     1            1           100s

$ oc delete deployment/cloudigrade-api
deployment.apps "cloudigrade-api" deleted

$ oc get deployment/cloudigrade-api
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
cloudigrade-api   0/1     1            0           7s
```

If only a specific pod appears to be misbehaving, you could delete that specific pod, and the deployments' HPAs and `minReplica` settings should recreate the pod as necessary. For example:

```
$ oc get pods -l pod=postigrade-svc
NAME                             READY   STATUS    RESTARTS   AGE
postigrade-svc-55db8d4b6-qpxln   2/2     Running   0          50s
postigrade-svc-55db8d4b6-tkrxx   2/2     Running   0          51s
postigrade-svc-55db8d4b6-xqzv8   2/2     Running   0          47m

$ oc delete pod/postigrade-svc-55db8d4b6-qpxln
pod "postigrade-svc-55db8d4b6-qpxln" deleted

$ oc get pods -l pod=postigrade-svc
NAME                             READY   STATUS              RESTARTS   AGE
postigrade-svc-55db8d4b6-nhbbm   0/2     ContainerCreating   0          4s
postigrade-svc-55db8d4b6-tkrxx   2/2     Running             0          80s
postigrade-svc-55db8d4b6-xqzv8   2/2     Running             0          47m
```
