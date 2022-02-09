# Accessing blackbox-exporter and domain-exporter

## blackbox-exporter

The blackbox-exporter used to be available via https://blackbox-exporter.devshift.net and https://blackbox-exporter.stage.devshift.net - these Routes were removed because they were publicly-accessible and rarely used by the team. To access them now, you can run the commands below to port-forward the Service endpoint:

For production, login to **app-sre-prod-01** and run:
```
oc -n app-sre-observability-production port-forward service/blackbox-exporter :9115
```

For stage, login to **app-sre-stage-01** and run:
```
oc -n app-sre-observability-stage port-forward service/blackbox-exporter :9115
```

The URL for CentralCI is still available at: http://10.0.132.216:9115

## domain-exporter

The domain-exporter used to be available via https://domain-exporter.devshift.net and https://domain-exporter.stage.devshift.net - these Routes were removed because they were publicly-accessible and rarely used by the team. To access them now, you can run the commands below to port-forward the Service endpoint:

For production, login to **app-sre-prod-01** and run:
```
oc -n app-sre-observability-production port-forward service/domain-exporter :9222
```

For stage, login to **app-sre-stage-01** and run:
```
oc -n app-sre-observability-stage port-forward service/domain-exporter :9222
```
