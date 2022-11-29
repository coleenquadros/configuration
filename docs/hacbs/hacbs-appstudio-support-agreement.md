# HACBS & AppStudio - app-interface Support Agreement

As discussed during [SDE-1909](https://issues.redhat.com/browse/SDE-1909), HACBS & AppStudio will not go over full onboarding in app-interface. Instead, they will use only a selected set of features.

## Support agreement

The app-interface components used by HACBS/AppStudio will be supported by AppSRE. HACBS & AppStudio will support their own services, and SRE will not carry the pager for them. If at some time in the future either team wants SRE support, then the agreement is to follow the regular SRE onboarding process which implies satisfying all the SRE Acceptance Criteria.

Note this hybrid SRE model is very new as of 2022-10-04. Further adaptations, discussions, agreements should be expected.

AppSRE supports the tooling around app-interface, as it does for all its tenants.
The HACBS & AppStudio teams can get support from @app-sre-ic in [#sd-app-sre](https://coreos.slack.com/archives/CCRND57FW) on this tooling, for the features that are agreed to be used, as listed in the next section. 

## App-interface features agreed to be used by HACBS & AppStudio

As of 2022-10-04:
* Preference to use clusters provided by appSRE but experimentation is done with the current provisioned HACBS cluster from appSRE (hacbss02ue1) and a bring your own cluster.
* For the workload clusters:
  * Have the observability stack applied which includes logging aggregation to cloudwatch and Prometheus/alertmanager
  * The target is to deploy the KCP syncer (includes a clusterrole and clusterrolebinding) via a saas file.
* For the service provider workspaces:
  * Secrets management from appSRE's Vault instance
* Vault instance access could be done either by:
  * app-interface management to land secrets to the KCP workspace
  * Having access to vault directly
      * It is agreed that the AppSRE's Vault instance has no SLO / SLA and **must not be used at runtime by applications**. AppSRE will however ensure Vault is available most of the time since it is used a lot as part of the standard app-interface tooling for all its tenants.
      * This will be re-examined once Vault moves behind the VPN.
* AWS resources integrations, like RDS database and S3 bucket. Credentials to be put in KCP workspaces or in workload clusters

## Features to be used by HACBS & AppStudio that is not app-interface or unsure if it will be used in app-interface

As of 2020-10-04:
* For the HACBS service provider workspaces:
  * HACBS' own instance of argo will deploy all the manifests for the applications
* CI - builds
* servicemonitors
* Alerting such as slack usergroup management, SLOs, etc.

## Other Resources

* [Recording](https://drive.google.com/file/d/1WpyX05WNji3aFiO7rchR6sVENcbM1Ct-/view) from October 4, 2022
