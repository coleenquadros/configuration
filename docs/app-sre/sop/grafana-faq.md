# Grafana FAQ

Grafana URL: https://grafana.app-sre.devshift.net/

## Access: 

The access to the app-sre Grafana instance is managed through the [app-interface](https://gitlab.cee.redhat.com/service/app-interface)

To get access, add this line to your corresponding user.yaml

`- $ref: /services/observability/permissions/observability-access.yml`

For example: https://gitlab.cee.redhat.com/service/app-interface/merge_requests/158/diffs

## Adding a new Grafana dashboard

1. Go to https://grafana.app-sre.devshift.net/ and login
2. From the 'Manage Dashboards' tab, select 'PlayG

## Modifying an existing Grafana dashboard

## Deleting an existing Grafana dashboard