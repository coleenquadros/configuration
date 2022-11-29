# KCP - app-interface Support Agreement

As discussed during [SDE-1733](https://issues.redhat.com/browse/SDE-1733), KCP will not go over full onboarding
in app-interface. Instead, KCP will use only a selected set of features.

## Support agreement
The KCP service itself will not be supported by AppSRE. The application support & oncall is fully on the KCP team side. As such, KCP is not subject to the [standard AppSRE contract](https://gitlab.cee.redhat.com/app-sre/contract). Note this hybrid SRE model is very new as of 2022-10-03. Further adaptations, discussions, agreements should be expected.

AppSRE supports the tooling around app-interface, as it does for all its tenants.
The KCP team can get support from @app-sre-ic in [#sd-app-sre](https://coreos.slack.com/archives/CCRND57FW) on this tooling, for the features that are agreed to be used, as listed in the next section. 

## App-interface features agreed to be used by KCP

As of 2022-10-03:
* Bring-you-own cluster. KCP will reference their cluster in app-interface
* Standard AppSRE observability stack deployment over this cluster
* Vault AppRole to manage `/control-plane-service/*` (See [MR 48835](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/48835))
  * This will be re-examined once Vault moves behind the VPN. The KCP team considers moving their ArgoCD server behind the VPN as well
  * It is agreed that the AppSRE's Vault instance has no SLO / SLA and **must not be used at runtime by applications**. AppSRE will however ensure Vault is available most of the time since it is used a lot as part of the standard app-interface tooling for all its tenants.
