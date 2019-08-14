# SOP : SREOperators Alert

<!-- TOC depthTo:2 -->

- [SOP : SREOperators](#SREOperators)

<!-- /TOC -->

---

## Hive Operator Target is down

### Impact:
Metrics are not being scraped from an SRE Hive operator on one of the hive clusters. 

### Summary:
The URL of the route is unacccesable to the App SRE prometheus. This could be related to a few things.
1) The metrics endpoint on the operator pods
2) The Service pointing to the pod's endpoint
3) The Route exposing the service with a public URl. 

### Resolution:
First check the status of the Route. There is a known router bug that causes the Route to fail
when a new deployment of an operator goes out (https://bugzilla.redhat.com/show_bug.cgi?id=1723527).
Delete the Rotue and try to roll out a new operator pod. This will trigger the creation of a new Route.
If the Route looks to be in a good state, check the Service and if it looks to be in an errored state roll out a new pod like above. 
If the Service object has no obvious errors, rsh into a pod and try to curl the endpoint. Service DNS has a predictable naming scheme.
For example, the aws-account-operator Service endpoint would look like: aws-account-operator.aws-account-operator.svc.cluster.local:8080/metrics
If you recieve an error or a 404, it is likely an issue with the pod's endpoint.
Check the operator logs to see if there was an error starting the metrics. Usually its an error with a particular metric being registered or updated.
In this case, it will need a code fix most likely.
Otherwise, restart the pod and see if the metrics endpoint is happy.
