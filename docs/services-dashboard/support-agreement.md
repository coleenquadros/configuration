# Services Dashboard - app-interface Support Agreement

Services Dashboard will not go over full onboarding in app-interface. Instead, Services Dashboard will use only a selected set of features.

## Support agreement
The Services Dashboard service itself will not be supported by AppSRE. The application support & oncall is fully on the Services Dashboard team side. As such, Services Dashboard is not subject to the [standard AppSRE contract](https://gitlab.cee.redhat.com/app-sre/contract).

AppSRE supports the tooling around app-interface, as it does for all its tenants.

The Services Dashboard team can get support from @app-sre-ic in [#sd-app-sre](https://coreos.slack.com/archives/CCRND57FW) on this tooling, for the features that are agreed to be used, as listed in the next section.

## App-interface features agreed to be used by Services Dashboard

As of 2022-12-13:
* Services Dashboard team will only use the AppSRE:
  * Deployment pipeline
  * OpenShift cluster
  * Vault (reexamined when Vault moves behind the VPN)
  * Observability stack
* It is agreed that the AppSRE's Vault instance has no SLO / SLA and **must not be used at runtime by applications**. AppSRE will however ensure Vault is available most of the time since it is used a lot as part of the standard app-interface tooling for all its tenants.
