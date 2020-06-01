# Quay.io Builder Cluster

## Builder Cluster Access & Setup

Quay builder OCP cluster access and setup instructions can be found [here](quay-builder-ocp-cluster-setup/README.md).

## Builder Cluster

[OpenShift Console](https://console-openshift-console.apps.c1.ocp4-builder.quay.io/k8s/ns/builder/jobs)

## Terminate All Builds

Sometimes, you may need to terminate all builds running on builder cluster. Each `build` runs as a `job`. The best way to terminate all `builds` is by terminating all `jobs` in the `builder` namespace on the cluster.

```sh
oc project builder && oc get jobs | tail -n +2 | awk '{print $1}' | while read line; do oc delete job $line; done
```

## Authentication & Service Account

[Quay.io](https://quay.io) authenticates with the builder cluster using [quay-builder-sa](https://console-openshift-console.apps.c1.ocp4-builder.quay.io/k8s/ns/builder/serviceaccounts/quay-builder-sa) service account token.

## Add/Remove bare-metal Worker Nodes

Builder cluster has two machine sets. You can scale the machine setup up/down to add/remove nodes from OpenShift console. Because `m5.metal` nodes are expensive (~$4000/month) we only run single node.

1. [EC2 Virtual Machines](https://console-openshift-console.apps.c1.ocp4-builder.quay.io/k8s/ns/openshift-machine-api/machine.openshift.io~v1beta1~MachineSet/c1-gjlfl-worker-us-east-1d) running misc workload.
2. [EC2 Bare-Metal m5.metal](https://console-openshift-console.apps.c1.ocp4-builder.quay.io/k8s/ns/openshift-machine-api/machine.openshift.io~v1beta1~MachineSet/c1-gjlfl-builder-worker-us-east-1d) running Quay builds.

Note that every time you add a new `m5.metal` node to the cluster, you will need to manually accept any pending certificate request. Node cannot join the cluster until its certificate signing request (CSR) has been approved. See [setup docs](quay-builder-ocp-cluster-setup/README.md#approve-csr-for-machineset) for commands.

## Updating OpenShift Cluster

Follow steps from OpenShift [documentation](https://docs.openshift.com/container-platform/4.1/updating/updating-cluster.html) to upgrade the cluster. Cluster upgrades must be scheduled during a Quay.io maintenance window.

## Understanding Quay Build Queue SLI

Quay publishes following SLI for build queue:

- `quay_queue_items_available_unlocked` - backlog of builds
- `quay_queue_items_available` - unlocked + any expired locked items
- `quay_queue_items_locked` - non-expired locked items

The SLI we should look at is `quay_queue_items_available`.
