# SOP : Openshift Cincinnati

<!-- TOC depthTo:2 -->

- [SOP : OpenShift Cincinnati](#sop--openshift-cincinnati)
    - [Verify it's working](#verify-its-working)
    - [PEIncomingRequestsHalted](#peincomingrequestshalted)
    - [PEUpstreamErrors](#peupstreamerrors)
    - [PEGraphResponseErrors](#pegraphresponseerrors)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Verify it's working

- At least one `cincinnati` pod is marked as UP in Prometheus.

## PEIncomingRequestsHalted

### Summary:

Policy-engine is not receiving/processing client requests.

### Impact:

Clusters are not receiving updates hints.
Cluster-Version-Operator (CVO) could be hanging or showing errors on clusters console.

### Access required:

- Access to the cluster that runs Cincinnati, namespaces:
    - cincinnati-staging
    - cincinnati-production

### Steps:

- Investigate pod connectivity.
- Contact Cincinnati team, investigate why policy-engine is not processing client requests.

---

## PEUpstreamErrors

### Summary:

Policy-engine is working and processing client request, but its upstream graph-builder is returning errors.

### Impact:

Clusters are not receiving updates hints.
Cluster-Version-Operator (CVO) is showing errors on clusters console.

### Access required:

- Access to the cluster that runs Cincinnati, namespaces:
    - cincinnati-staging
    - cincinnati-production

### Steps:

- Contact Cincinnati team, investigate why policy-engine is not processing client requests.

---

## PEGraphResponseErrors

### Summary:

Policy-engine is working and processing client requests, but many of them result in errors.

### Impact:

Clusters are not receiving updates hints.
Cluster-Version-Operator (CVO) is showing errors on clusters console.

### Access required:

- Access to the cluster that runs Cincinnati, namespaces:
    - cincinnati-staging
    - cincinnati-production

### Steps:

- Contact Cincinnati team, investigate why policy-engine is generating error-reponses.

---

## Escalations

Slack: #forum-auto-updates

Developers:
 * @steveej
 * @luca.bruno
 * @shiywang

Slack alerts: #team-cincinnati-alerts

Team email: aos-team-cincinnati@redhat.com 

