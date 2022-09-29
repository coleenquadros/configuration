# Prometheus Flapping targets

## Description

Generally speaking, Prometheus targets are monitored using the `up` metric to check if a target is down `for` a determined amount of time.
The `up` metric only has `1` or `0` as possible values.

Example:

```yaml
- alert: FooTargetIsDown
  expr: absent(up{job="foo"}) == 0
  for: 5m
```

This alert fires if the condition expr is `true` for 5 minutes, but it does not detect flapping states. For example, the target could be `Down` 4/5 minutes every 5 minutes interval
of 1 hour, and the alert won't fire. To improve the detection of this situations there is a flapping state detection alert.

```yaml
- alert: PrometheusTargetFlapping
  expr: changes(up{namespace="ns"}[15m]) >= 4 # 2 changes
  for: 1m
```

This alert will fire if the range vector returned by the `up` metric has more changes (0 to 1 or 1 to 0) in its values than the defined threshold. This way we can detect if there
are status changes in the targets.

## Troubleshooting

This alert is meant to detect changes in the targets, additional troubleshooting is required to get the causes of a flapping state.

### Possible causes

#### Scrape duration

If a target scrapping ends in a timeout, the target is turned to a `down` state until a successful scrapping occurs. Depending the case, the scrape timeout of the target could be increased
to solve this case.

#### Target Issues

Check the target related alerts or target backend logs. Targets sometimes are multiple pods and if one of them is misbehaving it might cause a flapping state.
