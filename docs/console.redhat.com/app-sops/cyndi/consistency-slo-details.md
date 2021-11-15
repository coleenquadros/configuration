# Cyndi Data Consistency SLO Details

## SLI description

Measure the percentage of data in sync between Host Inventory and each app.

## SLI Rationale

This is the primary function of Cyndi, to synchronize data from the Host Inventory into applications.

## Implementation details

The cyndi_inconsistency_ratio is the result of periodically comparing the Host Inventory database with the synchronized data in the app database.

## SLO Rationale

Due to some legacy issues with Host Inventory event processing the data is never 100% in sync, so 99% is the closest we will achieve.

## Alerts
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/xjoin-prod/cyndi.prometheusrules.yaml#L62


