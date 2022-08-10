# Recycle the terraform user access key

To recycle the access key of a terraform user, you need to delete the old access key, create a new one and place it into Vault.

## Deleting an access key

If a key needs to be deleted as fast as possible

1. log into the AWS console, find the `terraform` user in IAM and delete the access key in the `Security credentials` section
2. Keep track of the key ID and add it to the `deletedKeys` section of the respective `/aws/account-1.yml` in app-interface for traceability.

Step 2. is sufficient to delete a key but takes a bit longer due to the app-interface MR and reconcile process.

## Create a new access key

1. log into the AWS console, find the `terraform` user in IAM and create a new access key in the `Security credentials` section
2. place the access key ID and the secret access key into the vault secret defined in `/aws/account-1.yml#automationToken.path`
