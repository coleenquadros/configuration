## Observatorium sending status codes other than 2xx

### Impact

No data can be sent or received from Observatorium. Which directly impacts dashboards as well as user facing metrics used by the Kas Fleet Manager API.

### Summary

Observatorium is not able to send or receive metrics. Resulting in status codes other than 2xx being sent.

### Access required

- OSD console access to the cluster that runs the Managed services Token refresher.
- Access to Grafana dashboards.
- Access to cluster resources: Pods/Secrets/Network policies.

### Relevant secrets

### Steps

1. Check both the KAS Fleet Manager and Token refresher pods logs for any errors.

2. In the token refersher pod 
    ```
    oc get pod <TOKEN_REFRESHER> -o json | jq  ".spec.containers[].env"
    ```
    Check the following are populated:
    - Observatorium url.  
        - Stage: `https://observatorium-mst.api.stage.openshift.com/api/metrics/v1/managedkafka`  
        - Production: `https://observatorium-mst.api.openshift.com/api/metrics/v1/managedkafka`     
    - Issuer URL 
        - Issuer URL:`https://sso.redhat.com/auth/realms/redhat-external`
    - For Client ID and Client Secret:
        ```
        oc get secret kas-fleet-manager-observatorium-configuration-red-hat-sso -n <namespace> -o go template --template="{{.data.grafana.clientId|base64decode}}"
        ```
        ```
        oc get secret kas-fleet-manager-observatorium-configuration-red-hat-sso -n <namespace> -o go template --template="{{.data.grafana.clientSecret|base64decode}}"
        ```

3. A status code of 0 is sent when a request timeout is reached. In these cases ensure the following should be checked:
* Network policy `token-refresher` is not misconfigured.  

    * Target pods:
        ```
        oc get networkpolicy -o json token-refresher | jq  .spec.podSelector.matchLabels
        {
        "app.kubernetes.io/component": "authentication-proxy",
        "app.kubernetes.io/name": "token-refresher"
        }
        ```
    * From:
        ```
        oc get networkpolicy -o json token-refresher | jq  ".spec.ingress[0].from[0].podSelector.matchLabels"
        {
        "app": "kas-fleet-manager",
        }

        ```

* Observatorium URL is not misconfigured:  
    ```    
    oc get pod <TOKEN_REFRESHER> -o json | jq  ".spec.containers[].env"
    ```
    - Stage: `https://observatorium-mst.api.stage.openshift.com/api/metrics/v1/managedkafka`  
    - Production: `https://observatorium-mst.api.openshift.com/api/metrics/v1/managedkafka`  

* Token refresher deployment is not down:  
    * Check if the KasFleetManagerTokenRefresherDown alert is firing.  
    * Check Token refresher pod is up and running.  

5. Ensure the status of the Observatorium instance is up and running.

    * In the Observatorium [Dashboard](https://grafana.app-sre.devshift.net/d/Tg-mH0rizaSJDKSADX/api?orgId=1&refresh=1m),  /query and /query_range panels are important as these are the endpoints the Kas Fleet manager uses.

## Escalations

If the problem cannot be solved escalate the issue to the Control Plane team. Escalation policy can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/managed-services/escalation-policies/kas-fleet-manager.yaml).

