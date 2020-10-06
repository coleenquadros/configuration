# SOP : OCM Sendgrid Service

<!-- TOC depthTo:2 -->

- [SOP : OCM Sendgrid Service](#sop-ocm-sendgrid-service)
  - [OCM Sendgrid Service Down](#ocm-sendgrid-service-down)  
  - [OCM Sendgrid Service 5xx Errors High](#ocm-sendgrid-service-5xx-errors-high)
  - [OCM Sendgrid Service 4xx Errors High](#ocm-sendgrid-service-4xx-errors-high)
  - [OCM Sendgrid Service Latency High](#ocm-sendgrid-service-latency-high)
  - [OCM Sendgrid Service Job(s) Failed](#ocm-sendgrid-service-jobs-failed)
  - [Sendgrid Service Dependencies](#sendgrid-service-dependencies)
  - [Sendgrid Service SubAccount Quota Low](#sendgrid-service-dependencies-sendgrid-subaccount-quota-low)
  - [Preflight Checks](#preflight-checks)
  - [Escalations](#escalations)

<!-- /TOC -->

---

## OCM Sendgrid Service Down

### Impact

New OCM clusters will be unable to generate Sendgrid credentials for SMTP service, which will currently block the installation of RHMI until the SMTP secret is detected in the cluster.
Existing clusters will be unable to rotate current Sendgrid credentials.
Sendgrid credentials will not be cleaned up for clusters in deletion, consuming unnecessary SubAccount quota.

### Summary

OCM Sendgrid Service is down

### Access required

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

- If the sendgrid service pod is crashing, check the pod logs (`deployment/ocm-sendgrid-service`) to investigate possible causes for the crash
- Investigate possible misconfiguration in the pod logs, for example errors reading secrets from vault or misconfiguration within the service template
- If the SendGrid service pod is failing on start up, check to see if preflight checks are failing. See [Preflight Checks](#preflight-checks) section of this SOP
- Investigate possible OCM outages that might be impacting the service uptime
- If cause of outage cannot be determined, escalate to the RHMI team (see escalation contacts)

---

## OCM Sendgrid Service 5xx Errors High

### Impact

New OCM clusters could be unable to generate Sendgrid credentials for SMTP services.
Existing clusters could be unable to rotate current Sendgrid credentials.
Sendgrid credentials might not be cleaned up for clusters in deletion.

### Summary

Sendgrid Service API is returning an abnormally high number of 5xx Error requests

### Access required

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

- Check `deployment/ocm-sendgrid-service` logs to determine why errors are occurring. 
- Check the RDS database instance connection (`ocm-sendgrid-service-<staging|production>`)
- Contact the RHMI team (see escalation contacts)

---

## OCM Sendgrid Service 4xx Errors High

### Impact

New OCM clusters could be unable to generate Sendgrid credentials for SMTP services.
Existing clusters could be unable to rotate current Sendgrid credentials.
Sendgrid credentials might not be cleaned up for clusters in deletion.

### Summary

Sendgrid Service API is returning an abnormally high number of 4xx Error requests

### Access required

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

- Check `deployment/ocm-sendgrid-service` logs to determine why errors are occurring
- Check the RDS database instance connection (`ocm-sendgrid-service-<staging|production>`)
- Contact the RHMI team (see escalation contacts)

---

## OCM Sendgrid Service Latency High

### Impact

New OCM clusters could be unable to generate Sendgrid credentials for SMTP services.
Existing clusters could be unable to rotate current Sendgrid credentials.
Sendgrid credentials might not be cleaned up for clusters in deletion.

### Summary

OCM Sendgrid Service API is experiencing high latency

### Access required

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

- Check `deployment/ocm-sendgrid-service` logs
- Contact the RHMI team (see escalation contacts)

---

## OCM Sendgrid Service Job(s) Failed

Sendgrid Service job has reached the maximum number of attempts.

### Impact

Sendgrid Subaccount or Credentials will not be created or synced to the cluster.

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

- Find max attempt value from Sendgrid Service Vault key `secrets/scheduler.maxRetry` : https://vault.devshift.net/ui/vault/secrets/app-interface/show/ocm-sendgrid-service/
- Find api key value from Sendgrid Service Vault key `secrets/sendgrid.key` : https://vault.devshift.net/ui/vault/secrets/app-interface/show/ocm-sendgrid-service/
- From the Sendgrid Service RDS instance (`ocm-sendgrid-service-<staging|production>`), find the cluster ids of all jobs that have reached the maximum retry 
  ```
  SELECT cluster_id FROM sendgrid_jobs WHERE attempts=<secrets/scheduler.maxRetry>;
  ```
- For each `cluster_id`
  - Ensure ocm is signed into the correct stage|production url:
    ```
    ocm account status
    ```
  - Check cluster if failed job exists:
    ```
    ocm get /api/clusters_mgmt/v1/clusters/<cluster_id>
    ```
  - If **cluster exists** - reset the attempts to 0 for the failed job:
    ```
    UPDATE sendgrid_jobs SET attempts=0 WHERE attempts=<secrets/scheduler.maxRetry> AND cluster_id=<cluster_id>;
    ```
  - If **cluster does not exist** - verify credentials are removed from sendgrid:
    ```
    curl -X "GET" "https://api.sendgrid.com/v3/subusers?username=<cluster_id>" -H "Authorization: Bearer <secrets/sendgrid.key>" -H "Content-Type: application/json"
    ```
    - If **sendgrid credential exist** (curl output was a non-emtpy array with a single entry with details of the subuser), reset attempts to 0 and mark job for deletion:
      ```
      UPDATE sendgrid_jobs SET attempts=0, remove=true WHERE attempts=<secrets/scheduler.maxRetry> AND cluster_id=<cluster_id>;
      ```
    - If **sendgrid credential does not exist** (curl output was an emtpy array - `[]%`), remove the failed job from the DB:
      ```
      DELETE FROM sendgrid_jobs WHERE attempts=<secrets/scheduler.maxRetry> AND cluster_id=<cluster_id>;
      ```
- Watch the logs for `deployment/ocm-sendgrid-service` for the service to execute job 
- If the job is continuously reaching the maximum number of attempts, verify that no other service interruptions are occurring
- Finally, escalate to the RHMI team (see escalation contacts), including the copied logs

---

## Sendgrid Service Dependencies

A dependency service is experiencing issues or has been downgraded.

### Sendgrid

The following rules are in place to alert on dependency service issues:

- Sendgrid 5xx Errors High
- Sendgrid 4xx Errors High
- Sendgrid Latency High

### Access required

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

- Contact SRE team for a service outage
- Copy any relevant logs from `deployment/ocm-sendgrid-service`
- Inform the RHMI team (see escalation contacts), including the copied logs

---

## Sendgrid Service Dependencies - Sendgrid SubAccount Quota low

Sendgrid SubAccount Quota is low

### Alerts

- OCM dependencies - Sendgrid SubAccount Quota less than 100
- OCM dependencies - Sendgrid SubAccount Quota less than 20

### Impact

New clusters will be unable to generate Sendgrid credentials for SMTP services.
Existing clusters will be unable to rotate current Sendgrid credentials.

### Relevant secrets

- secrets/ocm-sendgrid-service

### Steps

#### Raise Ticket with Sendgrid

- Raise a ticket with the Sendgrid team to increase the quota for  the account
- First get the SendGrid credentials in [vault](https://vault.devshift.net/ui/vault/secrets/app-interface/show/ocm-sendgrid-service/).
- The credential keys are `sendgrid.username` and `sendgrid.password`
- You can contact SendGrid support from the [SendGrid Support Portal](https://support.sendgrid.com/). Click Login & Contact Support and open a ticket to increase the quota.
#### Update Sendgrid quota secret
- Once Sendgrid has granted the new quota, the RHMI vault secret will need to be updated with the updated quota count. This env var is located in [vault](https://vault.devshift.net/ui/vault/secrets/app-interface/show/ocm-sendgrid-service/) and is called `sendgrid-subuser.quota`
- Finally, create an MR to bump the vault secret version in app-interface: https://gitlab.cee.redhat.com/service/app-interface/-/blob/1adb526/data/services/sendgrid/namespaces/sendgrid-stage.yml#L36

---

## Preflight Checks

Each time a SendGrid pod is initialised a series of preflight checks are run. The outcome of these checks will determine if the pod goes into a `Running` state.

### Database connection check

The SendGrid pod will attempt to connect to the database using the connection details stored in the `ocm-sendgrid-service-rds` secret in the SendGrid namespace.

In the event that the pod is unable to connect to the database, the following errors should be present in the pod logs:

`error connecting to the database: <err>`

### SendGrid configuration check

The OCM SendGrid service uses an API key to communicate with the external SendGrid API. This API key is stored in a vault secret under `sendgrid.key`. The vault secret is then created in the SendGrid namespace and mounted in each pod.

The SendGrid configuration check reads the value of `sendgrid.key` and performs create, list and delete operations against the SendGrid API. If these operations are unsuccessful, the following errors should be present in the pod logs:

`{"sendgrid_config_check":"failed to check sendgrid api connection: failed to list sendgrid subusers: failed to unmarshal sub users, content={\"errors\":[{\"field\":null,\"message\":\"access forbidden\"}]}: json: cannot unmarshal object into Go value of type []*sendgrid.SubUser"}%`

### OCM service account check

An SSO service account is required for the OCM SendGrid service to communicate with other OCM services. The account credentials are located in a vault secret under `ocm-service.clientId` and `ocm-service.clientSecret` respectively.

The OCM service account check reads in the value of both `ocm-service.clientId` and `ocm-service.clientSecret` and validates these credentials by running a simple `ocm whoami` query. Should this validation be unsuccessful, the following errors should be present in the pod logs:

`{"ocm_config_check\":"failed to check ocm account: can't get access token: unauthorized_client: Invalid client secret"}%`

## Escalations

Contact the RHMI team for any Sendgrid Service related alerts

### Contacts

Slack channel: `#rhmi-sendgrid-service`

- Aiden Keating (akeating@redhat.com)
- Ciaran Roche (croche@redhat.com)
- Dimitra Zuccarelli (dzuccare@redhat.com)
- Kevin Fan (chfan@redhat.com)
- Paul McCarthy (pamccart@redhat.com)
