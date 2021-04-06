## RHSSO-Operator Restart

Following steps helps to verify rhsso operator status and restart it if needed.


## Steps
- Verify the state of rhsso operator by running the following command:

    `
    oc get deployment rhsso-operator -n <namespace> -o json | jq '.status.readyReplicas'
    `

- Desired output value is 1. If it is not 1 , restart rhsso-operator by running:

    `
    oc rollout restart deployment rhsso-operator -n <namespace>
    `

- After few minutes verify that the rhsso operator pods are in ready state:

    `
    oc get pods -n <namespace>
    `

- The rhsso-operatpr-<random-id> pod should be running.

    ```
    NAME                                                              READY   STATUS     
    rhsso-operator-<ramdom-id>                                         1/1    Running    
    ```

- Verify that the RHSSO instance pods are up and running

    `
    oc get pods -n <namespace>
    `

    Depending upon the replicas (default is 3) , the keycloak-<id> pods should be running.
    
    ```
    NAME                                                              READY   STATUS     
    keycloak-0                                                        1/1     Running    
    keycloak-1                                                        1/1     Running    
    keycloak-2                                                        1/1     Running    
    ```
