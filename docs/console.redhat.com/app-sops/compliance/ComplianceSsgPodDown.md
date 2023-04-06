# Compliance alert no traffic
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
The Insights Compliance service enables IT security and compliance administrators to assess, monitor, and report on the security-policy compliance of RHEL systems. The compliance service provides a simple but powerful user interface, enabling the creation, configuration, and management of SCAP security policies. If Compliance is broken, customers aren't being able to use these functions.

## Summary
This alert fires when the pod responsible for servince SCAP content is not available. This can block both the Compliance and Remediations services from functioning properly.

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Log into the [console / namespace](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/compliance-prod/deployments) and verify that the complianc-ssg-service pod is running by clicking on the compliance-ssg-service deployment, going the Pods tab, and verify that the Status column says "Running" for the pod.
2. Confirm that the compliance-ssg-service pod is recieving requests by clicking on the pod, going to the Logs tab and verifying that there is activity in the logs.
3. Inspect compliance-ssg-service pod logs and search for error logs by clicking on a pod and then clicking on the Logs tab and searching for the word "Error"
4. Check if any deployments or changes in the application happened closer to the time the error started.
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/compliance/app.yml
