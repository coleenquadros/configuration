# Sources SLOs

## SLO

* Availability: Pods are down no longer than 2 minutes
* Restarts: Pods aren't restarted more than 5 times in 30 minutes for the last 1 hour
* Kafka lag: is less than 1000 in the last 10 minutes
* API: 
  * 90% of requests result in successful (non-5xx) response
  * Average request duration <= 500 ms for the last 10 minutes
* Satellite Ops:
  * Average number of errors was <= 10 per 10 mins for the last 30 minutes

## SLI

* https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/sources/sources.prometheusrules.yml

## Dashboards

* [Sources Dashboard](https://grafana.app-sre.devshift.net/d/zxZKNnAMz/sources?orgId=1)
