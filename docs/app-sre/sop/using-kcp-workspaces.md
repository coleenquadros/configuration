# Using KCP workspaces (under development)

The following SOP shows how to onboard a KCP workspace to app-interface. Give KCP is just a k8s API server, we can add a KCP workspaces as a cluser object in app-interface.

Be aware when reading this document: as of 10/2022 KCP is still undergoing big changes. 


[toc]

## Access token

KCP workspaces are provided by the KCP team. Reach out to #forum-kcp to get a workspace provisioned. For development purposes you can follow this guide to get a personal namespace: https://docs.google.com/document/d/1ygHQOBDMMnnsEDQoXSLSxaLUrplhOC42R3_kHCr25TI/edit#

In order to access KCP from app-interface, you need to provision a ServiceAccount and get a token from it. Use following resource deployment and apply it to the KCP workspace you want to access:

```
---
apiVersion: v1
kind: Namespace
metadata:
  name: workspace-admin

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: workspace-admin
  namespace: workspace-admin

---
apiVersion: v1
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: workspace-admin
  name: workspace-admin-token
  namespace: workspace-admin
type: kubernetes.io/service-account-token

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: workspace-admin
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: workspace-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: workspace-admin
subjects:
- kind: ServiceAccount
  name: workspace-admin
  namespace: workspace-admin 
```

You can fetch the token using the following command:

```
kubectl describe -n workspace-admin secret/workspace-admin-token
```

It needs to be store in vault, so we can use it as `automationToken`. 


## Adding the workspace in app-interface

```
---
$schema: /openshift/cluster-1.yml

labels:
  service: $workspace_name

name: $workspace_name
description: add some meaniningful description here
consoleUrl: ''
kibanaUrl: ''
prometheusUrl: ''
alertmanagerUrl: ''
serverUrl: $workspace_url
elbFQDN: ''

automationToken:
  path: abc
  field: token

internal: false

disable:
  integrations:
  - openshift-users
  - openshift-groups
  - openshift-clusterrolebindings
  - openshift-rolebindings
  - openshift-routes
  - openshift-network-policies
  - openshift-resourcequotas
  - openshift-limitranges
```

### Can I deploy everything?

You first must add a KCP syncer to an OpenShift cluster as a regular deployment (needs documentation!). Only if a syncer is deployed you can leverage the following resource types, that are deployed per default:

 * configmaps
 * deployments
 * secrets
 * serviceaccounts
