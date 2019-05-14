# SOP : OpenShift Telemeter

<!-- TOC depthTo:2 -->

- [SOP : OpenShift Telemeter](#sop--openshift-telemeter)
    - [ControllerErrorsHigh](#controllererrorshigh)
    - [InstallJobHighDuration](#installjobhighduration)
    - [HiveDown](#hivedown)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## ControllerErrorsHigh

### Impact: 

New clusters are not able to fetch an authorization token.
We are lucky if clusters are already authorized.
We issue clusters inside telemeter a JWT token for 12 hours.
All existing clusters will be okay for 12h window since last authorized.

The error is related to clusters which are either: 
- New clusters trying to authorize.
- Existing clusters who already have authorized,
but the 12h window for the token has expired

### Summary: 

Telemeter is recieving errors at a high rate from Tollbooth

### Access required:

- Console access to the cluster that runs telemeter (Currently app-sre OSD)
- Edit access to the Telemeter namespaces:
    - telemeter-stage
    - telemeter-production

### Steps: 

- Contact Tollbooth team, investigate why Tollbooth is failing to authorize cluster IDs.

---

## InstallJobHighDuration

### Impact: 

Clusters are not able to fetch a new authorization token or renew it.

### Summary: 

Telemeter server itself uses OAuth to authorize against tollbooth.
It uses an access token, issued by RedHat's OAuth server (Keycloak).
Telemeter is receiving error responses when trying to refresh the access token
at a high rate from Keycloak.

### Access required:

- Console access to the cluster that runs telemeter (Currently app-sre OSD)
- Edit access to the Telemeter namespaces:
    - telemeter-stage
    - telemeter-production

### Relevant secrets:

### Steps: 

- Contact Keycloak team, investigate why Keycloack is failing to authorize Telemeter server.

---

## HiveDown 

### Impact:

Clusters are not able to push metrics.

### Summary: 

Telemeter Server is down and not serving any requests.

### Access required:

- Console access to the cluster that runs telemeter (Currently app-sre OSD)
- Edit access to the Telemeter namespaces:
    - telemeter-stage
    - telemeter-production### Severity: Critical

### Steps:

- Contact monitoring engineering team to help in the investigation.
- Investigate failure of Telemeter server.
- Check Telemeter server logs.

---

## Escalations
We want a link to app-interface here, but okay to just contacts here for now. 
