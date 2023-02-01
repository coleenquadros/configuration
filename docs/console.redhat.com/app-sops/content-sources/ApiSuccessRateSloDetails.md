# API Success Rate SLO Details

## SLI description

Measurement of how often content sources API endpoints return a successful response.

## SLI Rationale

This directly relates to a healthy user experience. A lower error rate here is a sign of a healthy API.

## Implementation details

This SLI is represented by the expression: 

* 	sum(rate(content_sources_http_status_histogram_count{status!=”5xx”}[{{window}}])) / sum(rate(content_sources_http_status_histogram_count[{{window}}]))

The “content_sources_http_status_histogram_count{status!=”5xx”}” metric, which counts the number of successful requests, is divided by the “content_sources_http_status_histogram_count” metric, which counts the number of total requests. The resulting ratio is the success rate of all http requests.

## SLO Rationale

The 95% target is a healthy starting goal and may be adjusted in the future should the success rate be consistently higher.

## Alerts

We have multi-window multi-burn-rate alerts to track error budget burn.

The alerts are:
  - `ContentSources5mto1hErrorBudgetBurn`
  - `ContentSources30mto6hErrorBudgetBurn`
  - `ContentSources2hto1dErrorBudgetBurn`
  - `ContentSources6hto3dErrorBudgetBurn`

Links to prometheus rules: 
- [Stage prometheus rules][stage rules].
- [Production prometheus rules][prod rules].

[stage rules]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-stage/content-sources-stage/content-sources-stage.prometheusrules.yml
[prod rules]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/content-sources-prod/content-sources-prod.prometheusrules.yml
