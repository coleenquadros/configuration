# uhc-auth-proxy SLOs

## SLO

Availability:  99% of requests result in successful (non-5xx) response 
Latency:  99% of requests services in <2000ms 

## SLI

Availability:  sum(api_3scale_gateway_auth_status{service="apicast",auth_type="uhc-auth",status="5xx"})/sum(api_3scale_gateway_auth_status{service="apicast",auth_type="uhc-auth"}) < .99
Latency:  avg_over_time(service:sli:status_5xx:pctl5rate5m{environment="prod",exported_service="apicast-tests"}[7d]) < .99
