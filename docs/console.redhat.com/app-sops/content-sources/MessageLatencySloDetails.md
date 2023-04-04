# Message Latency SLO Details

## SLI description

Measurement of the proportion of task messages picked up in one hour or less.

## SLI Rationale

Users submitting work to the system should expect the work to be processed within a reasonable amount of time.

## Implementation details

This SLI is represented by the expression:

*    sum(rate(content_sources_message_latency_bucket{le="3600"}[{{window}}]))/sum(rate(content_sources_message_latency_count[{{window}}]))

The `content_sources_message_latency_bucket` histogram metric has buckets populated by the amount of time between when a message is dispatched and when it is picked up. The `content_sources_message_latency_count` metric is the total number of messages. The 1 hour bucket divided by the total number of requests gives the proportion of requests that return within 1 hour.

## SLO Rationale

The target is for 90% of messages to be picked up within 1 hour, but the target may be adjusted in the future based on the volume of traffic.

## Alerts

We have multi-window multi-burn-rate alerts to track error budget burn.

The alerts are:
- `ContentSourcesMessageLatency5mto1hrOr30mto6hBudgetBurn`
- `ContentSourcesMessageLatency2hrto1dOr6hrto3dBudgetBurn`

Links to Prometheus rules:
- [Stage prometheus rules][stage rules].
- [Production prometheus rules][prod rules].

[stage rules]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-stage/content-sources-stage/content-sources-stage.prometheusrules.yml
[prod rules]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/content-sources-prod/content-sources-prod.prometheusrules.yml
