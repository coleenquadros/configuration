# Stonesoup - app-interface Support Agreement

Onboarding epic: [SDE-1909](https://issues.redhat.com/browse/SDE-1909).

## Timelines and phases

SOA / Internal Customers / Demo:
- ArgoCD on a separated control plane cluster
- No fleet manager
- Continue managing secrets in vault.
- Continue managing AWS resources through App-Interface.

Service Preview I (June / July)
- Wait list, 200 users
- No fleet manager
- Accepted risk for customer data loss
- RTO 2 days
- Continue managing secrets in vault.
- Continue managing AWS resources through App-Interface.

Service Preview II (Date not set yet)
- No wait list > 1000 users
- Fleet manager required
- DR plan for customer data loss
- Dynamic secrets management
- Dynamic AWS resources management

More information about the phases can be found in this document [Mission Critical Stonesoup Summit May 23 and Beyond](https://docs.google.com/document/d/1Hjm5NPVUqwGrKbSq2GFdguYg7fEk_Rls4NU9b9A-ol4/edit#heading=h.g77075lsklqc).

## Onboarding Process

Stonesoup will onboard into AppSRE the control plane components which are:

- ArgoCD: Deployed as an operator from OperatorHub. This component will be used to deploy all the other components to the data plane clusters. ArgoCD's endpoint should be accessible by Stonesoup Hybrid SREs.
- ArgoCD CRs required for ArgoCD to deploy workloads into the data plane clusters.
- Observability CRs: Prometheus Rules with alerts
- Fleet Manager: Although this component is necessary to support the fleet management capabilities of the data plane, this is not in scope until Service Preview II and it's currently (2023-03-21) under design / development.

As of 2023-03-21, the key onboarding issues and questions:
- Decide whether to use RHOBS or AppSRE hosted Prometheus for the observability of the data plane.
- Decide if RHACM is suitable as a fleet manager piece, or if the FFM (Factorized Fleet Manager) should be used instead, or a third solution.
- Define SLIs/SLOs.
- Runbooks for alerts / SLOs.
- Decide Networking set up for data plane clusters (although this does not block the onboarding of the control plane components into App-Interface).
- [Service Preview II] Secret management as required by data plane cluster provisiong.
- [Service Preview II] Cloud resources required by data plane components.

## Data plane

The data plane consists of two types of clusters:

- Host clusters
- Member clusters

Both types of clusters run different kinds of workloads. These workloads will be controlled by the control plane ArgoCD.

Initially, the data plane clusters will be statically defined (without cluster management). However, Service Preview II requires the existence of a Fleet Manager component to handle new provisions, deprovisionings, etc. Without this component the RTO will be set to 2 days.

## Support agreement

- Control plane supported by AppSRE. This component will manage the data plane.
- Data plane exposes metrics via the control plane. Control plane can also manage components in the data plane through GitOps (ArgoCD). This allows AppSRE to support data plane issues as well (as long as they're surface through alerts and have a runbook associated with them).
  - Anything not exposed/controllable from the control plane is not under AppSRE support.

## Notable Changes

* Document was originally prepared on 2022-10-04.
* Document was revised substantially on 2023-01-05, to reflect a [decision](https://docs.google.com/document/d/1ONrBWVlbdGZIIEanEtiUP3daUCKmrGgehk2VtPhN-Mk/edit) from the [ARB](https://source.redhat.com/departments/products_and_global_engineering/oo_cto/red_hat_office_of_the_cto_wiki/architecture_review_board_arb) to drop KCP from the
architecture.
* Document has been reworked on 2023-03-21 as it is now a regular AppSRE onboarding for the control plane.

## Other Resources

* [Recording](https://drive.google.com/file/d/1WpyX05WNji3aFiO7rchR6sVENcbM1Ct-/view) from October 4, 2022
