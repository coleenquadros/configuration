# App-interface build master job failure

The app-interface build master job is running the [build_deploy.sh](/hack/build_deploy.sh) script.

This script has 3 steps:

1. `make bundle` - bundle the data in the repository.
2. `make validate` - validate the bundle created in the previous step.
3. Upload the bundle to the app-interface-production S3 bucket in the app-sre AWS account.

If the build master job is failing, look at the logs to understand which step failed, and debug accordingly.

In most cases, if this job failed, it is related to the last Merge Request tha was merged.

If the failure does not seem to be related to the last changes, try to run the job again.

If the failure persists and the error is still not found, try to revert the last changes and create a bug in Jira.
