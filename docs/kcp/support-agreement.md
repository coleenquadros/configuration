# KCP - app-interface Support Agreement

As discussed during [SDE-1733](https://issues.redhat.com/browse/SDE-1733), KCP will not go over full onboarding
in app-interface. Instead, KCP will use only a selected set of features.

This document lists the features that were agreed to be used.

As of 2022-10-03:
* Bring-you-own cluster. KCP will reference their cluster in app-interface
* Observability stack deployment over this cluster
* Vault AppRole to manage `/control-plane-service/*` (See [MR 48835](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/48835))
  * It is agreed that the app-sre vault instance has not SLO / SLA and should not be used at runtime by applications.
  * This will be re-examined once vault moves behind the VPN. The KCP team considers moving their ArgoCD server behind the VPN as well
