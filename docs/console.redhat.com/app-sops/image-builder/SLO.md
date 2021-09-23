# Image Builder SLO

## SLO

1. Processing of compose requests: 85% should succeed
2. Responsiveness: 90% of requests should be fast

## SLIs
1. Percentage of successful (non-5xx) compose requests
```
1 - (sum by (job) (increase(image_builder_compose_errors[24h])) / sum by (job)
(increase(image_builder_compose_requests_total[24h]))) >= 0.85
```
2. Average time to handle request:
   * Compose requests:
```
histogram_quantile(0.90,
sum(rate(image_builder_http_duration_seconds_bucket{path=~".*compose"}[1h])) by (le))
<= 12
```
   * Non-compose requests:
```
histogram_quantile(0.90,
sum(rate(image_builder_http_duration_seconds_bucket{path!~".*compose"}[1h])) by (le))
<= 0.2
```

## Dashboards

[Image Builder Grafana dashboard](https://gitlab.cee.redhat.com/tgunders/app-interface/-/merge_requests/new?merge_request%5Bsource_branch%5D=image-builder-sop)
