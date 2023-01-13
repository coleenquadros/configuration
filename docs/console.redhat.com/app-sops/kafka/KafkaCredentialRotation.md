## Rotation Process for Kafka Access Credentials

### Impact

RHOSAK (Red Hat OpenShift Streams for Apache Kafka, Managed Kafka) requires client authentication as detailed in [RHOSAK KafkaAuth Configuration
](https://docs.google.com/document/d/1MFJmHFXBT6vycDyb_AllV3cgj5WzUI6frlBWItD1YCw/).

In the event of a RHOSAK credential rotation or leak, this SOP document outlines the process of affecting credential changes and informing affected applications.  

With Kafka forming a major backbone of the ConsoleDot infrastructure, any delay in providing updated credentials to apps will delay the bulk of work on the platform.

### Process Steps

1. Notify applications of pending Kafka outage a credentials change
2. Create new service account at console.redhat.com under the console-dot account
    1. ` rhoas service-account create --output-file=./service-acct-credentials.json`
3. Give new service account Consume/Produce ACLs in affected RHOSAK cluster
    1. `rhoas login`
    2. `rhoas kafka use --name [consoledot-stage|consoledot-prod]`
    3. `rhoas kafka acl grant-access --producer --user [service account id] --topic all`
    4. `rhoas kafka acl grant-access --consumer --user [service account id] --topic all --group all`
4. Update secrets in Vault that reference the affected creds:
    1. insights/secrets/insights-[prod|stage]/strimzi-[prod|stage]/[clowder-auth|app-auth]
5. Update secret versions in app-interface
    1. See https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/51623/diffs for sample
6. Inform app teams of new secrets so they can update external references to secrets
7. Remove old service account from RHOSAK ACLs
    1.  `rhoas kafka acl delete --service-account "[service account id] --pattern-type=all"`
8. Delete old service account
    1. `rhoas service-account delete --id [service account id]`


### Escalations

See https://visual-app-interface.devshift.net/services#/services/insights/devprod/app.yml
