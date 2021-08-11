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

2. Check the Observatorium url is correct.  
    - Stage: `https://observatorium-mst.api.stage.openshift.com/api/metrics/v1/managedkafka`  
    - Production: `https://observatorium-mst.api.openshift.com/api/metrics/v1/managedkafka`
        
3. Check Client ID, Client Secret and Issuer URL are being populated.
    * Issuer URL:`https://sso.redhat.com/auth/realms/redhat-external`

4. A status code of 0 is sent when a request timeout is reached. In these cases ensure the following should be checked:
    * Network policy `token-refresher` is not misconfigured.  
        - Target pods:
            ```
            Pod selector:
            app.kubernetes.io/component=authentication-proxy
            app.kubernetes.io/name=token-refresher
            ```
        - From:
            ```
            Namespace:
            managed-services-stage
            Pod selector:
            app=kas-fleet-manager, operator.prometheus.io/name=app-sre
            ```
        - To ports:  
            ```
            Any port
            ```  
    * Observatorium URL is not misconfigured:  
        - Stage: `https://observatorium-mst.api.stage.openshift.com/api/metrics/v1/managedkafka`  
        - Production: `https://observatorium-mst.api.openshift.com/api/metrics/v1/managedkafka`  
        
    * Token refresher deployment is not down:  
        * Check if Token refresher down alert is firing.  
        * Check Token refresher pod is up and running.  
    
5. Ensure the status of the Observatorium instance is up and running.

    * In the Observatorium [Dashboard](https://grafana.app-sre.devshift.net/d/Tg-mH0rizaSJDKSADX/api?orgId=1&refresh=1m),  /query and /query_range panels are important as these are the endpoints the Kas Fleet manager uses.

## Escalations

If the problem cannot be solved escalate the issue to the Control Plane team. Escalation policy can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/managed-services/escalation-policies/kas-fleet-manager.yaml).

