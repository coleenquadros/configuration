# SOP : App SRE contract alerts

<!-- TOC depthTo:2 -->

- [SOP : App SRE contract alerts](#sop--app-sre-contract-alerts)
    - [AppSREContractDeploymentReplicasUnder3](#appsrecontractdeploymentreplicasunder3)
    - [AppSREContractStatefulSetReplicasUnder3](#appsrecontractstatefulsetreplicasunder3)

<!-- /TOC -->

---

## AppSREContractDeploymentReplicasUnder3

### Summary:

Deployment is running with under 3 replicas.

### Steps:

- Contact service owner.

---

## AppSREContractStatefulSetReplicasUnder3

### Summary:

StatefulSet is running with under 3 replicas.

### Unknown Cases Steps:

- Contact service owner.

### Knwon Cases Steps

#### hccm-prod/hive-metastore

Alert message:

```
StatefulSet hccm-prod/hive-metastore has 1 replicas (< 3)
```

Steps:

* Check the status of the ticket [https://issues.redhat.com/browse/COST-1351](https://issues.redhat.com/browse/COST-1351).
* Ping the owners if you see fit.
* Silence the alert for 7d.

---
