# uhc-auth-proxy SLOs

## SLO

Availability:  99% of requests result in successful (non-5xx) response 
Latency:  99% of requests services in <2000ms 

## SLI

Availability:  Result of https://issues.redhat.com/browse/RHCLOUD-9572
Latency:  avg_over_time(service:sli:status_5xx:pctl5rate5m{environment="prod",exported_service="uhc-auth-proxy"}[7d])
