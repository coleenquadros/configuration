# SOP : OCM Sendgrid Service

<!-- TOC depthTo:2 -->

- [SOP : OCM Sendgrid Service](#sop-ocm-sendgrid-service)
    - [Sendgrid Service Down](#sendgrid-service-down)  
    - [Sendgrid Service 5xx Errors High](#sendgrid-service-5xx)
    - [Sendgrid Service 4xx Errors High](#sendgrid-service-4xx)
    - [Sendgrid Service Latency High](#sendgrid-service-latency-high)
    - [Sendgrid Service Job Failed](#sendgrid-service-job-failed)
    - [Sendgrid Service Dependencies](#sendgrid-service-dependencies)
    - [Sendgrid Service SubAccount Quota Low](#sendgrid-service-dependencies-sendgrid-subaccount-quota-low)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Sendgrid Service Down

### Impact:

New OCM clusters will be unable to generate Sendgrid credentials for SMTP service, which will currently block the installation of RHMI until the SMTP secret is detected in the cluster.
Existing clusters will be unable to rotate current Sendgrid credentials.
Sendgrid credentials will not be cleaned up for clusters in deletion, consuming unnecessary SubAccount quota.


### Summary:

Sendgrid Service is down

### Access required:

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:

- If the sendgrid service pod is crashing, check the pod logs (`deployment/ocm-sendgrid-service`) to investigate possible causes for the crash 
- Investigate possible misconfiguration in the pod logs, for example errors reading secrets from vault or misconfiguration within the service template 
- Investigate possible OCM outages that might be impacting the service uptime 
- If cause of outage cannot be determined, escalate to the RHMI team (see escalation contacts)

---

## Sendgrid Service 5xx

### Impact:

New OCM clusters could be unable to generate Sendgrid credentials for SMTP services.
Existing clusters could be unable to rotate current Sendgrid credentials. 
Sendgrid credentials might not be cleaned up for clusters in deletion.

### Summary:

Sendgrid Service API is returning an abnormally high number of 5xx Error requests

### Access required:

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:

- Check `deployment/ocm-sendgrid-service` logs to determine why errors are occurring. 
- Check the RDS database instance connection (`ocm-sendgrid-service-<staging|production>`)
- Contact the RHMI team (see escalation contacts) 

---

## Sendgrid Service 4xx

### Impact:

New OCM clusters could be unable to generate Sendgrid credentials for SMTP services.
Existing clusters could be unable to rotate current Sendgrid credentials. 
Sendgrid credentials might not be cleaned up for clusters in deletion.

### Summary:

Sendgrid Service API is returning an abnormally high number of 4xx Error requests

### Access required:

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:

- Check `deployment/ocm-sendgrid-service` logs to determine why errors are occurring
- Check the RDS database instance connection (`ocm-sendgrid-service-<staging|production>`)
- Contact the RHMI team (see escalation contacts) 

---

## Sendgrid Service Latency High 

### Impact:

New OCM clusters could be unable to generate Sendgrid credentials for SMTP services.
Existing clusters could be unable to rotate current Sendgrid credentials. 
Sendgrid credentials might not be cleaned up for clusters in deletion.

### Summary:

Sendgrid Service API is experiencing latency

### Access required:

- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:

- Check `deployment/ocm-sendgrid-service` logs
- Contact the RHMI team (see escalation contacts) 

---

## Sendgrid Service Job Failed 

Sendgrid Service job has reached the maximum number of attempts.

### Impact: 

Sendgrid Subaccount or Credentials will not be created or synced to the cluster. 

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:
- From the Sendgrid Service RDS instance (`ocm-sendgrid-service-<staging|production>`), reset the attempts to 0 for the failed job:
```
$ UPDATE sendgrid_jobs SET attempts=0 WHERE id = '{{$labels.jobID}}';
```
- Watch the logs for `deployment/ocm-sendgrid-service` for the service to execute job 
- If the job is continuously reach the maximum number of attempts, verify that no other service interruptions are occurring
- Finally, escalate to the RHMI team (see escalation contacts), including the copied logs

---

## Sendgrid Service Dependencies

A dependency service is experiencing issues or has been downgraded.

### Sendgrid
The following rules are in place to alert on dependency service issues:
- Sendgrid 5xx Errors High
- Sendgrid 4xx Errors High 
- Sendgrid Latency High

### Access required:
- Console access to the cluster that runs the sendgrid service (app-sre)
- Edit access to the namespaces:
  - sendgrid-<stage|production>

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:
- Contact SRE team for a service outage
- Copy any relevant logs from `deployment/ocm-sendgrid-service` 
- Inform the RHMI team (see escalation contacts), including the copied logs

---

## Sendgrid Service Dependencies - Sendgrid SubAccount Quota low

Sendgrid SubAccount Quota is low

### Alerts
- OCM dependencies - Sendgrid SubAccount Quota less than 100
- OCM dependencies - Sendgrid SubAccount Quota less than 20 

### Impact:

New clusters will be unable to generate Sendgrid credentials for SMTP services.
Existing clusters will be unable to rotate current Sendgrid credentials. 

### Relevant secrets:
- secrets/ocm-sendgrid-service

### Steps:
#### Raise Ticket with Sendgrid
- Raise a ticket with the Sendgrid team to increase the quota for  the account
- First get the SendGrid credentials in the RHMI vault `/rhmi/ocm-sendgrid-service/<stage|production>/ocm-sendgrid-service`
- The credential keys are `sendgrid.username` and `sendgrid.password`
- You can contact SendGrid support from the [SendGrid Support Portal](https://support.sendgrid.com/). Click Login & Contact Support and open a ticket to increase the quota.
#### Update Sendgrid quota secret
- Once Sendgrid has granted the new quota, the RHMI vault secret will need to be updated with the updated quota count. This env var is located in `rhmi/ocm-sendgrid-service/<stage|production>/ocm-sendgrid-service` in Vault and is called `sendgrid-subuser.quota`
- Finally, create an MR to bump the vault secret version in app-interface: https://gitlab.cee.redhat.com/service/app-interface/-/blob/1adb526/data/services/sendgrid/namespaces/sendgrid-stage.yml#L36

---

## Escalations

Contact the RHMI team for any Sendgrid Service related alerts

### Contacts:

Slack channel: `#rhmi-sendgrid-service`

- Aiden Keating (akeating@redhat.com)
- Ciaran Roche (croche@redhat.com)
- Dimitra Zuccarelli (dzuccare@redhat.com)
- Kevin Fan (chfan@redhat.com)
- Paul McCarthy (pamccart@redhat.com)
