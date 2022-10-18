# Using KCP workspaces (under development)

Be aware when reading this document: as of 10/2022 KCP is still undergoing big changes. 


[toc]

## Access token

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

## Adding the workspace

```
---
$schema: /openshift/cluster-1.yml

labels:
  service: $workspace_name

name: $workspace_name
description: Insights CCS cluster for ephemeral environment
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
  e2eTests: []
```
