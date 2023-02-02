# API Request Latency SLO Details

## SLI description

Measurement of the proportion of HTTP requests to the content sources API that respond within 100ms.

## SLI Rationale

This directly relates to a healthy user experience, as a fast return results in a responsive user experience.

## Implementation details

This SLI is represented by the expression: 

* sum(rate(content_sources_http_status_histogram_bucket{le="0.1",path!="/api/content-sources/v1.0/repository_parameters/validate"}[{{window}}])) / sum(rate(content_sources_http_status_histogram_count[{{window}}]))

The `content_sources_http_status_histogram_bucket` histogram metric has buckets populated by the duration of each request to the content sources API. The `content_sources_http_status_histogram_count` metric is the total number of requests. The 0.1 second bucket divided by the total number of requests gives the proportion of requests that return within 100ms.

The validate endpoint is excluded because it sometimes reaches out to the internet to grab files, which can cause delays outside of our app's control. 

## SLO Rationale

The target is for 95% of requests to return within 100ms, but the target may be adjusted in the future based on the volume of traffic. 

## Alerts

We have multi-window multi-burn-rate alerts to track error budget burn.

The alerts are:
- `ContentSourcesLatency5mto1hrOr30mto6hBudgetBurn`
- `ContentSourcesLatency2hto1dOr6hto3dBudgetBurn`

Links to Prometheus rules: 
- [Stage prometheus rules][stage rules].
- [Production prometheus rules][prod rules].

[stage rules]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-stage/content-sources-stage/content-sources-stage.prometheusrules.yml
[prod rules]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/content-sources-prod/content-sources-prod.prometheusrules.yml
