# Restore AWS Secrets Manager secret

For the secrets manager, AppSRE provides tenants with [iam-service-account](https://gitlab.cee.redhat.com/service/app-interface#manage-secrets-manager-service-account-users-via-app-interface-openshiftnamespace-1yml) which has access to secrets with a particular prefix. The actual secrets are created and managed by tenants' service, which can also be accidentally deleted. AWS provides not immediately deleted but scheduled for deletion after a default to a 30-day recovery window. Before the end of the recovery window, AppSRE can recover the secret and make it accessible again.

## Steps

1. Tenants need to contact @app-sre-ic with the secret name which needs to be restored.
1. an AppSRE engineer will be required to execute the following commands in this SOP. 

    Check the status of the secret
    ```
    aws secretsmanager describe-secret --secret-id <SECRTE_NAME> 
    ```
    Example output:
    ```
    {
        "ARN": "arn:aws:secretsmanager:us-east-1:XXX:secret:managed-connectors/XXX",
        "Name": "managed-connectors/XXX",
        "LastChangedDate": "2023-01-18T04:11:41.400000-05:00",
        "LastAccessedDate": "2023-01-17T19:00:00-05:00",
        "DeletedDate": "2023-01-18T04:11:41.389000-05:00",
        "Tags": ...
        "VersionIdsToStages": ...
        "CreatedDate": "2023-01-18T04:07:41.330000-05:00"
    }
    ```
    Restore the secret
    ```
    aws secretsmanager restore-secret --secret-id <SECRTE_NAME>
    ```
