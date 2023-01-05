# Stonesoup - app-interface Support Agreement

As discussed during [SDE-1909](https://issues.redhat.com/browse/SDE-1909), Stonesoup will not go over full onboarding in app-interface. Instead, they will use only a selected set of features.

## Support agreement

The app-interface components used by Stonesoup will be supported by AppSRE. Stonesoup will support their own services, and SRE will not carry the pager for them. If at some time in the future either team wants SRE support, then the agreement is to follow the regular SRE onboarding process which implies satisfying all the SRE Acceptance Criteria.

AppSRE supports the tooling around app-interface, as it does for all its tenants.
The Stonesoup teams can get support from @app-sre-ic in [#sd-app-sre](https://redhat-internal.slack.com/archives/CCRND57FW) on this tooling, for the features that are agreed to be used, as listed in the next section.

## Notable Changes

* Document was originally prepared on 2022-10-04.
* Document was revised substantially on 2023-01-05, to reflect a [decision](https://docs.google.com/document/d/1ONrBWVlbdGZIIEanEtiUP3daUCKmrGgehk2VtPhN-Mk/edit) from the [ARB](https://source.redhat.com/departments/products_and_global_engineering/oo_cto/red_hat_office_of_the_cto_wiki/architecture_review_board_arb) to drop KCP from the architecture.

Note this hybrid SRE model is very new as of 2022-10-04. Further adaptations, discussions, agreements should be expected.

## App-interface features agreed to be used by Stonesoup

As of 2023-01-05:

* Preference is to use clusters provided by appSRE. Request and details to be formalized in [STONE-248](https://issues.redhat.com/browse/STONE-248).
* The originally provisioned HACBS cluster (hacbss02ue1) is no longer needed, and can be decomissioned.
* For the service provider namespaces where stonesoup controllers run:
  * Secrets management from appSRE's Vault instance. app-interface management will be used to land
    secrets in the service provider namespaces.
  * AWS resources integrations, like RDS database and S3 bucket. app-interface management will be
    used to provide connection information to the service provider namespaces.

Additionally:

* It is agreed that the AppSRE's Vault instance has no SLO / SLA and **must not be used at runtime by applications**. AppSRE will however ensure Vault is available most of the time since it is used a lot as part of the standard app-interface tooling for all its tenants.

## Features to be used by Stonesoup that is not app-interface or unsure if it will be used in app-interface

As of 2023-01-05:
* For the Stonesoup service provider workspaces:
  * Stonesoup's own instance of argo will deploy all the manifests to the service provider
    namespaces for the applications
* CI - builds
* servicemonitors
* Alerting such as slack usergroup management, SLOs, etc.

## Other Resources

* [Recording](https://drive.google.com/file/d/1WpyX05WNji3aFiO7rchR6sVENcbM1Ct-/view) from October 4, 2022
