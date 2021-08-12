# Image Builder SLO

## SLO

1. Uptime: 90%
2. Processing of compose requests: 85% should succeed over 24h
3. Responsiveness:
   * Under 8 seconds for compose requests
   * Under 200ms for all other requests

## SLIs
1. Percentage of time that the pod is in the `up` state
```
avg(avg_over_time(up{service="image-builder"}[24h])) >= 0.90
```
2. Percentage of successful (non-5xx) compose requests
```
1 - (sum by (job) (increase(image_builder_compose_errors[24h])) / sum by (job)
(increase(image_builder_compose_requests_total[24h]))) >= 0.85
```
3. Average time to handle request:
   * Compose requests:
```
(sum by (job)
(rate(image_builder_http_duration_seconds_sum{path=~".*compose"}[1h])) / sum by
(job) (rate(image_builder_http_duration_seconds_count{path=~".*compose"}[1h])))
<= 8
```
   * Non-compose requests:
```
(sum by (job)
(rate(image_builder_http_duration_seconds_sum{path!~".*compose"}[1h])) / sum by
(job) (rate(image_builder_http_duration_seconds_count{path!~".*compose"}[1h])))
<= 0.2
```

## Dashboards

[Image Builder Grafana dashboard]()
