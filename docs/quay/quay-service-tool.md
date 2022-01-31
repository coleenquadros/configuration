# Quay Service Tool

This is a lightweight internal tool to help SEs with day-to-day chores like re-enabling users, resetting accounts, re-sending invoices etc. The tool uses python-flask on the backend and PatternFly React on the frontend. The upstream repository can be found [here](https://github.com/quay/quay-service-tool).

## OpenShift Clusters

| Environment | Console URL | URL
| --- | --- | --- |
|Stage|[Console](https://console-openshift-console.apps.quays02ue1.s6d1.p1.openshiftapps.com/k8s/ns/quay/deployments/quayio-service-tool)| http://service-tool.stage.quay.io/
|Production | In Progress | http://service-tool.quay.io/ (In Progress)

## Tool Access

This tool runs behind Redhat's SSO (OIDC) and can be accessed by members part of the `quay-service-tool-admin-access` group on [stage](https://rover.stage.redhat.com/groups/group/quay-service-tool-admin-access).

## Database user

This tool uses database user different from the root user. This database user credentials can be found for stage [here](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-stage/quayio-stage/quay-db-jobs) and for production [here](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-db-jobs). This database user has restricted access to the tool based on the tables used in this tool. 

## Reporting Errors

In case of any errors on the tool, please reach out to `#forum-quay` on [CoreOS](https://app.slack.com/client/T027F3GAJ/C7WH69HCY).
