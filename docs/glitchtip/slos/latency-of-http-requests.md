# Latency of HTTP Requests

## SLI description
We measure The ratio of the number of HTTP requests with latencies less than 500 milliseconds and the total number of HTTP requests.

## SLI Rationale

As a web service, GlitchTip's most interesting event from a monitoring perspective is an HTTP request. A successful HTTP request with acceptable incurred latency fulfills the following major HTTP request sources;

* API calls initiated from the a GlitchTip component (e.g. UI, worker, etc)
* API calls initiated by a user's HTTP client (e.g. Application that uses sentry SDK)


## Implementation details

The following is the explanation of the SLI query:

    sum(rate(django_http_requests_latency_seconds_by_view_method_bucket{le="0.5", job="glitchtip-web"}[28d])) by(job)
    /
    sum(rate(django_http_requests_latency_seconds_by_view_method_bucket{le="+Inf", job="glitchtip-web"}[28d])) by(job) * 100 >= 90


* `django_http_requests_latency_seconds_by_view_method_bucket` - Queries the total number of HTTP requests with latencies
* The rate function ensures missing metrics are extrapolated
* The sum function aggregates all the responses/requests by job.
* The whole query queries the derived ratio of total number of HTTP requests with latencies less than 500 milliseconds and the total number of HTTP requests regardless of their latencies.

## SLO Rationale

The target response time for 90 percent of the requests should be less than or equal to 500[ms]. This can be changed once this latency SLO has been observed with performance in production over a longer period of time.

## Alerts

The following are the multi-window, multi-burn-rate alerts that are associated with this SLO.

- LatencyBudgetBurn
