## RHSSO-Instance Restart

Following steps helps to verify RHSSO instance(s) status and restart it if needed.

### Steps

- Restart the RHSSO Instance stateful set:

    `
    oc rollout restart statefulset keycloak -n <namespace>
    `
- After few minutes check if RHSSO instance (i.e. keycloak-* pods) is up and running:

    `
    oc get pods -n <namespace>
    `
