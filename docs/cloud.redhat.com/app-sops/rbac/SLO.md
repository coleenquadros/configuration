# rbac SLOs

## SLO

Availability:  99% of requests result in successful (non-5xx) response 
Latency:  99% of requests services in <2500ms 

## SLI

Availability:  avg_over_time(service:sli:status_5xx:pctl5rate5m{environment="prod",exported_service="rbac"}[7d])
Latency:  sum(django_http_requests_latency_including_middlewares_seconds_bucket{le="2.5", namespace="rbac-prod"} )/sum(django_http_requests_latency_including_middlewares_seconds_bucket{le="+Inf", namespace="rbac-prod"})

## Dashboards

https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&from=now-7d&to=now&var-datasource=crcp01ue1-prometheus&var-label=rbac
