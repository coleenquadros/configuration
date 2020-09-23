# SLI recording rules generation via openshift-performance-parameters integration

The `openshift-performance-parameters` integration creates Prometheus recording rules for a defined set of SLI for each namespace in which a service is running. The SLIs currently supported are:

* volume
* availability
* latency
* errors

SLOs are about time. We will be recording if the service meets the criteria established in the performance parameters file for each of the SLIs considered. Then we will be able to query from Prometheus to show how those SLIs have been met over time, e.g in a VALET dashboard or from Alert Manager.

SLI recording rules are defined in the service performance parameters files that follow the [`/app-sre/performance-parameters-1.yml`](/schemas/app-sre/performance-parameters-1.yml) schema. In this document we're going to see the different sections of that schema and how they are used to generate the different rules. It is important to know that if your service has multiple components and/or multiple namespace, you should create separate performance parameter files per component and per namespace.

To make things easier to follow, we will go through the performance parameters of the `yak-shaver` component of the `yolo` service running in a certain namespace of one of the `app-sre` clusters. That component has a `read` API and a `write` API for which we will define different SLOs.

This document is not a substitute for the schema. Please read it to understand which of the fields of the examples are mandatory and how to go beyond the example proposed with the additional fields described in the performance parameters schema.

## General service description

### Unique name of the performance parameter rules

``` yaml
name: yolo-yak-shaver-production
```

### Labels

They will be used in all the recording rules to be able to query them.

```yaml
labels:
  service: yolo
  component: yak-shaver
```

### Reports

They link the documentation explaining how the SLOs have been determined (load tests, business requirements, etc). Please don't link here a JIRA issue

```yaml
reports:
  date: 2020-05-07
  url: https://docs.google.com/document/d/yolo-yak-shaver-performance-doc
```

### Application

Cross reference to the application yaml file

```yaml
app:
  $ref: /services/yolo/app.yml
```

and name of the component

```yaml
component: yak-shaver
```

### Prometheus Labels

Labels that Prometheus uses to select this rules file. These labels are added to the generated Manifest's metadata.labels.

```yaml
prometheusLabels:
  prometheus: app-sre
  role: alert-rules
  type: slo-rules
```

### Namespace

Namespace that this app lives in

```yaml
namespace:
  $ref: /services/yolo/namespaces/yolo-production.yml
```

## SLI base recording rules

In order to create the final recording rules for our SLIs we need to start with existing base metrics that give us an idea of:

* Amount of requests dispatched.
* how long are those requests taking

It is ideal that these two metrics are measured outside of the application, e.g. openshift router, AWS ELB, etc,  but it is mandatory that at least the amount of requets dispatched come from outside as we need to be able to measure when the application is returning HTTP 5xx because it is not working. In that case we would not be able to get any metric from it.

The `SLIRecordingRules` section of the performance schema defines these base recording rules for the different APIs of our `yak-shaver` component.

* The `haproxy_backend_http_responses_total` metric will give us request and errors ratio rates. It is necessary that it is a metric that has HTTP status codes.
* The `http_request_duration_seconds_bucket` will be used to measure latencies. It is convenient that it supports HTTP status codes as we will have more control over what we measure.

Those two metrics are generic. There's nothing in their names that is specific neither to the `yolo` service nor the `yak-shaver` component. In order to select the values from our service, we will have to specify the appropriate [selectors](https://prometheus.io/docs/prometheus/latest/querying/basics/#time-series-selectors). Note that it is possible to define selectors with the following operators: `=~`, `!=`, `!~`, and of course `=` (as in the example).

Our example defines 4 base SLI recording rules using the above metrics for our two APIs. The generated recording rules only show the `5m` range to keep things short, but we will generate rates for `5m, 30m, 1h, 2h, 6h, 1d` ranges

Names MUST be unique.

### Request rates

These are defined using the `http_rate` kind.

```yaml
- name: read_http_rates
  kind: http_rate
  metric: haproxy_backend_http_responses_total
  selectors:
  - route="yak-shaver-read"

- name: write_http_rates
  kind: http_rate
  metric: haproxy_backend_http_responses_total
  selectors:
  - route="yak-shaver-write"
```

They will generate the following recording rules for the `5m` range:

```yaml
- expr: |
    sum by (status_class) (
      label_replace(
        rate(haproxy_backend_http_responses_total{route="yak-shaver-read"}[5m]
      ), "status_class", "${1}xx", "code", "([0-9])..")
    )
  labels:
    component: yak-shaver
    route: yak-shaver-read
    service: yolo
  record: status_class:http_requests_total:rate5m
- expr: |
    sum by (status_class) (
      label_replace(
        rate(haproxy_backend_http_responses_total{route="yak-shaver-write"}[5m]
      ), "status_class", "${1}xx", "code", "([0-9])..")
    )
  labels:
    component: yak-shaver
    route: yak-shaver-write
    service: yolo
  record: status_class:http_requests_total:rate5m
- expr: |
    sum(status_class:http_requests_total:rate5m{route="yak-shaver-read",status_class="5xx"})
    /
    sum(status_class:http_requests_total:rate5m{route="yak-shaver-read"})
  labels:
    component: yak-shaver
    route: yak-shaver-read
    service: yolo
  record: status_class_5xx:http_requests_total:ratio_rate5m
- expr: |
    sum(status_class:http_requests_total:rate5m{route="yak-shaver-write",status_class="5xx"})
    /
    sum(status_class:http_requests_total:rate5m{route="yak-shaver-write"})
  labels:
    component: yak-shaver
    route: yak-shaver-write
    service: yolo
  record: status_class_5xx:http_requests_total:ratio_rate5m
```

We can see that the `selectors` set in the `SLIRecordingRules` definitions are used in the queries that build the recording rules. This is needed as `haproxy_backend_http_responses_total` is a metric name that will be used across many service/components in our Prometheus server. You will also see how the `=` selectors get turned into `labels`, but not the rest.

### Latency rates

These are defined using the `http_rate` kind for the p95 of the latency.

```yaml
- name: read_latency_p95
  kind: latency_rate
  percentile: 95
  metric: http_request_duration_seconds_bucket
  selectors:
  - job="yak-shaver-read"

- name: write_latency_p95
  kind: latency_rate
  percentile: 95
  metric: http_request_duration_seconds_bucket
  selectors:
  - job="yak-shaver-write"
```

They will generate the following recording rules for the `5m` range:

```yaml
- expr: |
    histogram_quantile(
      0.95,
      sum(rate(http_request_duration_seconds_bucket{job="yak-shaver-read"}[5m])) by (le)
    )
  labels:
    component: yak-shaver
    job: yak-shaver-read
    service: yolo
  record: component:latency:p95_rate5m
- expr: |
    histogram_quantile(
      0.95,
      sum(rate(http_request_duration_seconds_bucket{job="yak-shaver-write"}[5m])) by (le)
    )
  labels:
    component: yak-shaver
    job: yak-shaver-write
    service: yolo
  record: component:latency:p95_rate5m
```

## Errors, Latency, Availability and Volume SLOs

Every SLO definition below is composed of the following elements:

* A base recording rule to use in its calculation
* A target value we want our SLI to comply with. That can be incorporated into a higher level element such as a dashboard or an alarm
* A time window that we will calculate our SLO against. It will be 24h unless indicated otherwise.

### Errors

We define two SLOs for errors using the `http_rate` errors ratio rate rules created above, we will refer to them using the name we gave them. It should be noted that errors refer to HTTP 5xx status errors, not to 4xx errors. While it is important to track 4xx errors we cannot create SLOs on top of them as we don't have full control over them.

* Read API SLO definition expresses that errors ratio should be under 5% in the last 28 days
* Write API SLO definition expresses that errors ratio should be under 5% in the last 28 days

```yaml
errors:
- name: read_errors_slo
  kind: SLO
  rules: read_http_rates
  target: 5

- name: write_errors_slo
  kind: SLO
  rules: write_http_rates
  target: 1
```

They will generate the following recording rules for the `5m` range:

```yaml
- expr: |
    status_class_5xx:http_requests_total:ratio_rate5m{component="yak-shaver",route="yak-shaver-read",service="yolo"}
    < bool(5)
  labels:
    component: yak-shaver
    route: yak-shaver-read
    service: yolo
  record: component:errors:slo_ok_5m
- expr: |
    status_class_5xx:http_requests_total:ratio_rate5m{component="yak-shaver",route="yak-shaver-write",service="yolo"}
    < bool(1)
  labels:
    component: yak-shaver
    route: yak-shaver-write
    service: yolo
  record: component:errors:slo_ok_5m
```

Then if we want to calculate if your the read errors SLO has been met in the last day we could use the following PromQL query to compare with the `5%` target define above:

```promql
avg_over_time(component:errors:slo_ok_5m{
  component="yak-shaver",
  route="yak-shaver-read",
  service="yolo"
}[1d]) * 100
```

### Latency

Since latency cannot be expressed as a percentage, apart from a target we need a latency `threshold` that will indicate if we're not meeting our objective.  We define two SLOs for latency using the `latency_rate` rules above:

* Read API SLO definition expresses that the p95 of the latency should be under 0.5 seconds the 99.9% of the last 28 days
* Write API SLO definition expresses that the p95 of the latency should be under 1 seconds the 98% of the last 28 days

```yaml
latency:
- name: read_latency_slo
  kind: SLO
  rules: read_latency_p95
  threshold: 0.5
  target: 99.9

- name: write_latency_slo
  kind: SLO
  rules: write_latency_p95
  threshold: 1
  target: 98
```

They will generate the following recording rules for the `5m` range:

```yaml
- expr: |
    component:latency:p95_rate5m{component="yak-shaver",job="yak-shaver-read",service="yolo"}
    < bool(0.5)
  labels:
    component: yak-shaver
    job: yak-shaver-read
    service: yolo
  record: component:latency:slo_ok_5m
- expr: |
    component:latency:p95_rate5m{component="yak-shaver",job="yak-shaver-write",service="yolo"}
    < bool(1)
  labels:
    component: yak-shaver
    job: yak-shaver-write
    service: yolo
  record: component:latency:slo_ok_5m
```

that we can use to generate PromQL queries that use the `target` above.

## Availability

Availability is defined as a boolean product between latency and errors SLOs. This can help us track how our system is performing measured in different points, as it is usual that latencies are measured from inside the application and error ratios from a router level. Since latencies won't be properly tracked if application is down we have another way to determine how our system is performing.

We will define one availability SLO from our two APIs. In order to simplify we will use the above latency and errors rules, but we could have generated others specific to be used in the availability SLO.

* Read API SLO definition expresses that the `read_latency_slo` and `read_errors_slo` have to be met the 95% of the time
* Write API SLO definition expresses that the `write_latency_slo` and `write_errors_slo` have to be met the 95% of the time

```yaml
availability:
- name: read_availability_slo
  kind: SLO
  rules:
    latency:
    - read_latency_slo
    errors:
    - read_errors_slo
  target: 95

- name: write_availability_slo
  kind: SLO
  rules:
    latency:
    - write_latency_slo
    errors:
    - write_errors_slo
  target: 95
```

They will generate the following recording rules for the `5m` range:

```yaml
- expr: |
    component:latency:slo_ok_5m{component="yak-shaver",job="yak-shaver-read",service="yolo"}
    *
    component:errors:slo_ok_5m{component="yak-shaver",route="yak-shaver-read",service="yolo"}
  labels:
    component: yak-shaver
    job: yak-shaver-read
    route: yak-shaver-read
    service: yolo
- expr: |
    component:latency:slo_ok_5m{component="yak-shaver",job="yak-shaver-write",service="yolo"}
    *
    component:errors:slo_ok_5m{component="yak-shaver",route="yak-shaver-write",service="yolo"}
  labels:
    component: yak-shaver
    job: yak-shaver-write
    route: yak-shaver-write
    service: yolo
```

Since `latency` and `errors` are array of rules, we could create an SLO that takes into account all APIs:

```yaml
- name: read_availability_slo
  kind: SLO
  rules:
    latency:
    - read_latency_slo
    - write_latency_slo
    errors:
    - read_errors_slo
    - write_errors_slo
  target: 95
```

that would generate the following rule for the `5m` range

```yaml
- expr: |
    component:latency:slo_ok_5m{component="yak-shaver",job="yak-shaver-read",service="yolo"}
    *
    component:latency:slo_ok_5m{component="yak-shaver",job="yak-shaver-write",service="yolo"}
    *
    component:errors:slo_ok_5m{component="yak-shaver",route="yak-shaver-read",service="yolo"}
    *
    component:errors:slo_ok_5m{component="yak-shaver",route="yak-shaver-write",service="yolo"}
  labels:
    component: yak-shaver
    service: yolo
  record: component:availability:slo_ok_5m
```

Since the `job` and `route` are different for the different rules, we cannot keep them in the labels by default. If we wanted to create a query using the metric derived from this recording rule, we would need to use the following selectors

```
{
  component="yak-shaver",
  job="",
  route="",
  service="yolo"
}
```

to differentiate from the other two we created before. If we want to avoid this kind of non-intuitive selectors, we can add custom labels to a generated recording rule via the `additionalLabels` parameter. You can define `additionalLabels` the same way as you define `selectors` (see above). In our case, we could define something like this

```yaml
- name: read_availability_slo
  kind: SLO
  rules:
    latency:
    - read_latency_slo
    - write_latency_slo
    errors:
    - read_errors_slo
    - write_errors_slo
  target: 95
  additionalLabels:
    - route="YAK-SHAVER-ALL"
    - job="YAK-SHAVER-ALL"
```

that would generate the following rule for the `5m` range

```yaml
- expr: |
    component:latency:slo_ok_5m{component="yak-shaver",job="yak-shaver-read",service="yolo"}
    *
    component:latency:slo_ok_5m{component="yak-shaver",job="yak-shaver-write",service="yolo"}
    *
    component:errors:slo_ok_5m{component="yak-shaver",route="yak-shaver-read",service="yolo"}
    *
    component:errors:slo_ok_5m{component="yak-shaver",route="yak-shaver-write",service="yolo"}
  labels:
    component: yak-shaver
    job: YAK-SHAVER-ALL
    route: YAK-SHAVER-ALL
    service: yolo
  record: component:availability:slo_ok_5m
```

### Volume

It could be argued that SLO volume is difficult to justify, but it will serve us as a way of knowing if we are going above the peak capacity we have determined for our service. We will not define a percentage target on volume SLO but a request per second target that will reflect what we consider peak performance.

We define two SLOs for volume using the `http_rate` rules created above, we will refer to them using the name we gave them.

* Read API SLO definition expresses that requests per second have to be under 1000 in the last 28 days
* Write API SLO definition expresses that requests per second have to be under 200 in the last 28 days

```yaml
volume:
- name: read_volume_slo
  kind: SLO
  rules: read_http_rates
  target: 1000

- name: write_volume_slo
  kind: SLO
  rules: write_http_rates
  target: 200
```

Although there's no need to create further rules to calculate this SLO as it is doable directly with the base `haproxy_backend_http_responses_total` metric, we provide the following recording rules as they may be helpful

```yaml
- expr: |
    status_class:http_requests_total:rate5m{component='yak-shaver',route='yak-shaver-read',service='yolo'}
    < bool(1000)
  labels:
    component: yak-shaver
    route: yak-shaver-read
    service: yolo
  record: component:volume:slo_ok_5m
- expr: |
    status_class:http_requests_total:rate5m{component='yak-shaver',route='yak-shaver-write',service='yolo'}
    < bool(200)
  labels:
    component: yak-shaver
    route: yak-shaver-write
    service: yolo
  record: component:volume:slo_ok_5m
```

## Next steps

There are a number of things to be done after this:

* Create dashboards automatically from performance parameters (grafana, valet, etc)
* how to agree on the SLO target values
* process to validate them and to improve them over time (SLO life-cycling)
* Standardize SLO reports once we have more experience with them
* ...and many more
