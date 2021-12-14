# SOP : OCM Consumers

Grafana: https://grafana.app-sre.devshift.net/d/KD5D6LKnz/ocm-consumers

<!-- TOC depthTo:2 -->

- [SOP : UHC Consumers](#sop--uhc)
    - [ConsumersDown](#consumers-down)
    - [BannedUsersHigh](#banned-users-high)
    - [UnbannedUsersHigh](#unbanned-users-high)
    - [MessageAgeHigh](#message-age-high)
    - [ErrorRateHigh](#error-rate-high)
    - [ConnectionRetryRateHigh](#connection-retry-rate-high)
    - [Escalations](#escalations)
  
<!-- /TOC -->

---

## Consumers Down

### Impact:

No UMB messages are being processed.
UMB messages will continue to exist in the queue for up to 24 hours. 
This outage should not cause missed messages, only delay their processing. 
This outage will, however, prevent any message-based operations from completing during that time.

### Summary:

OCM Consumers are down

### Access required:

- Console access to the cluster that runs uhc-acct-mngr-consumer (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/uhc-acct-mngr-consumer` logs to determine why pods are down.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Banned Users High

### Impact:

While this may be a false positive, an unexpected number of users have been banned and should be investigated.
Large groups of users may have been inappropriately banned from OCM. All banned users see unauthorizated errors and are unable to use UHC portal.

### Summary:

Abnormally high number of users have been banned.

### Access required:

- Console access to the cluster that runs uhc-acct-mngr-consumer (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/uhc-acct-mngr-consumer` logs to determine banned users.
- Total number can be determined via OCM
  - `ocm get accounts --parameter search="banned = 'true' and banned_at > '2021-12-07T00:00:00Z'"| jq -r .total`
- Ban reason can be determined via OCM
  - `ocm get accounts --parameter search="banned = 'true' and banned_at > '2021-12-07T00:00:00Z'"| jq -r .items[].ban_code`
- Ban reason may be for export compliance or due to disabling of their RHIT/canonical account.
- Reach out to relevant team to confirm if bans were valid or invalid.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Unbanned Users High

### Impact:

While this may be a false positive, an unexpected number of users have been unbanned and should be investigated.
Large groups of users may have been inappropriately unbanned from OCM.
Those users may have access to resources they should be restricted from.

### Summary:

Abnormally high number of users have been unbanned.

### Access required:

- Console access to the cluster that runs uhc-acct-mngr-consumer (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/uhc-acct-mngr-consumer` logs to determine unbanned users.
- Unlike with banned users, we don't have a similar way to check for unbanned users. 
  - Searching the logs for unbanned users and their reasoning is the best approach, followed by alerting the relevant teams.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Message Age High

### Impact:

UMB messages flowing into the Consumers are abnormally high. This will cause expected data reconciling to be delayed.
This may include both user and subscription data. May point to deeper issues in processing time or external dependencies.

### Summary:

Abnormally high UMB message age.

### Access required:

- Console access to the cluster that runs uhc-acct-mngr-consumer (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/uhc-acct-mngr-consumer` logs to determine if there are any errors or timeouts associated with the delay in processing.
  - Errors and processing time can be correlated via Grafana (linked above)
  - If no client side errors or processing time issues, and message age is not decreasing, RHIT Platform Team should be alerted.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Error Rate High

### Impact:

Abnormally high error rates may cause delays in processing of related messages, or lost messages if errors are not resolved within 24 hours.

### Summary:

Abnormally high error rate.

### Access required:

- Console access to the cluster that runs uhc-acct-mngr-consumer (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/uhc-acct-mngr-consumer` logs to determine errors.
  - Nature of errors would determine next steps. Most likely suspects are:
    - Errors form UMB: Contact RHIT Platform Team
    - Errors from OCM: Contact SDB Team
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Connection Retry Rate High

### Impact:

Abnormally high connection retry rates may cause delays in processing of related messages, or lost messages if errors are not resolved within 24 hours.
This could be a wider outage of the UMB or a localized outage.
Connection retries may be caused by disconnect errors from the UMB or by network related issues.

### Summary:

Abnormally high connection retry rate.

### Access required:

- Console access to the cluster that runs uhc-acct-mngr-consumer (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/uhc-acct-mngr-consumer` logs to determine connection retry reason.
- Retry is most likely due to a network, UMB outage. or invalid UMB data. Inquire with RHIT Platform team.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Escalations

### Contacts:

- Abhishek Gupta (agupta@redhat.com)
- Timothy Williams (tiwillia@redhat.com)
- Brandon Vulaj (bvulaj@redhat.com)
