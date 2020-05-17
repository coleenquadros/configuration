# Remove GitLab webhooks to old Jenkins instances

To remove webhooks in GitLab projects to Jenkins instances which we no longer use, add the Jenkins instance URL to the `previousUrls` section in a Jenkins instance file.

Example: [ci-int](/data/dependencies/ci-int/ci-int.yml#L15)

The deletion will be done by the `jenkins-webhookd-cleaner` integration.
