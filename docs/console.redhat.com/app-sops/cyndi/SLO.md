# Cyndi SLOs

## SLO

* Latency:  Consumer lag of Cyndi Kafka connectors is less than 10 000 messages 95% of the time
* Consistency: The syndicated data is at least 99% consistent with the HBI database 95% of the time

## SLI

* [Latency](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=quantile_over_time(0.95%2C%20cyndi%3Aconsumer_group_lag%3Amin_per_app%5B1w%5D)&g0.tab=1)
* [Consistency](https://prometheus.crcp01ue1.devshift.net/graph?g0.range_input=1h&g0.expr=1%20-%20max(quantile_over_time(0.95%2C%20cyndi_inconsistency_ratio%5B1w%5D))%20by%20(app%2C%20namespace)&g0.tab=1)

## Dashboards

* [Cyndi Dashboard](https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/cyndi?orgId=1&refresh=1m&var-datasource=crcp01ue1-prometheus)
