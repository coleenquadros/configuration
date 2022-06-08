# Availability of HTTP Requests

## SLI description
We measure the ratio of the total number of successful HTTP requests and the total number of HTTP requests regardless of status.

## SLI Rationale

As a web service, GlitchTip's most interesting event from a monitoring perspective is an HTTP request. A successful HTTP request fulfills the following major HTTP request sources;

* API calls initiated from the a GlitchTip component (e.g. UI, worker, etc)
* API calls initiated by a user's HTTP client (e.g. Application that uses sentry SDK)

## Implementation details

The following is the explanation of the SLI query.

    sum(rate(django_http_responses_total_by_status_total{job="glitchtip-web",status!~"5.+"}[1d])) by (job)
    / sum(rate(django_http_requests_total_by_method_total{job="glitchtip-web"}[1d])) by (job)


* `django_http_responses_total_by_status_total` - Queries the total number of HTTP responses by HTTP status
* `django_http_requests_total_by_method_total` - Queries the total number of HTTP requests by method
* The `rate` function ensures missing metrics are extrapolated properly.
* The `sum` function aggregates all the responses/requests by job.
* The whole query queries the derived ratio of total number of HTTP responses that were successful and the total number of HTTP requests regardless of status.

## SLO Rationale

TODO: We will update this section as soon as the results in our testing (e.g. performance, acceptance) become available. We are going to use the results of these tests to decide on an SLO target. For now we use greater than or equal to 95% as we believe it is the most conservative threshold as of this stage.

## Alerts

TODO: There are not alert associated to this SLO yet as we are still performing relevant tests to gather more data in designing effective SLO-based alerts.
