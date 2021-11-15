# Cyndi Latency SLO Details

## SLI description

Measure the lag when synchronizing data between Host Inventory and apps.

## SLI Rationale

Too much lag will result in a poor experience for end users.

## Implementation details

The cyndi:consumer_group_lag metric is a Kafka metric to measure the lag (in number of messages) between producing and conuming messages.

## SLO Rationale

Some lag is inevitable. During periods when lots of uploads are being processed the lag may spike. This is why the limit is at 10,000.

## Alerts
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/xjoin-prod/cyndi.prometheusrules.yaml#L18
