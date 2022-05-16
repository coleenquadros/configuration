# Latency of HTTP Requests

## SLI description
We measure The ratio of the number of HTTP requests with latencies less than 500 milliseconds and the total number of HTTP requests.

## SLI Rationale

As a web service, GlitchTip's most interesting event from a monitoring perspective is an HTTP request. A successful HTTP request with acceptable incurred latency fulfills the following major HTTP request sources;

* API calls initiated from the a GlitchTip component (e.g. UI, worker, etc)
* API calls initiated by a user's HTTP client (e.g. Application that uses sentry SDK)


## Implementation details

The following is the explanation of the SLI query:

    sum(rate(django_http_requests_latency_seconds_by_view_method_bucket{le="0.5"}[5m])) by(job) / sum(rate(django_http_requests_latency_seconds_by_view_method_bucket{le="+Inf"}[5m])) by(job)


* `django_http_requests_latency_seconds_by_view_method_bucket` - Queries the total number of HTTP requests with latencies
* The rate function ensures missing metrics are extrapolated
* The sum function aggregates all the responses/requests by job.
* The whole query queries the derived ratio of total number of HTTP requests with latencies less than 500 milliseconds and the total number of HTTP requests regardless of their latencies.

## SLO Rationale

TODO: We will update this section as soon as the results in our testing (e.g. performance, acceptance) become available. We are going to use the results of these tests to decide on an SLO target. For now we use less than or equal to 500 milliseconds as we believe it is the most conservative threshold as of this stage.

## Alerts

TODO: There are no alert associated to this SLO yet as we are still performing relevant tests to gather more data in designing effective SLO-based alerts.
