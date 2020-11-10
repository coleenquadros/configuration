# uhc-auth-proxy SLOs

## SLO

Availability:  99% of requests result in successful (non-5xx) response 
Latency:  99% of requests services in <2000ms 

## SLI

Availability:  sum(api_3scale_gateway_auth_status{service="apicast",auth_type="uhc-auth",status="5xx"})/sum(api_3scale_gateway_auth_status{service="apicast",auth_type="uhc-auth"}) < .99
Latency:  sum(api_3scale_gateway_auth_time_bucket{auth_type="uhc-auth",le="2000.0"})/sum(api_3scale_gateway_auth_time_bucket{auth_type="uhc-auth",le="+Inf"}) < .99
