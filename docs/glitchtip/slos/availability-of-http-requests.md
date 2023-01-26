# Availability of HTTP Requests

## SLI description
We measure the ratio of the total number of successful HTTP requests and the total number of HTTP requests regardless of status.

## SLI Rationale

As a web service, GlitchTip's most interesting event from a monitoring perspective is an HTTP request. A successful HTTP request fulfills the following major HTTP request sources;

* API calls initiated from the a GlitchTip component (e.g. UI, worker, etc)
* API calls initiated by a user's HTTP client (e.g. Application that uses sentry SDK)

## Implementation details

The following is the explanation of the SLI query.

	sum(rate(haproxy_backend_http_responses_total{exported_namespace="glitchtip-stage", code!="5xx"}[1d])) by (exported_namespace) /
	sum(rate(haproxy_backend_connections_total{backend=~".*https.*", exported_namespace="glitchtip-stage"}[1d])) by (exported_namespace)


* `haproxy_backend_http_responses_total` - Queries the total number of HTTP responses by response code.
* `haproxy_backend_connections_total` - Queries the total number of HTTP connections by exported namespace.
* The `rate` function ensures missing metrics are extrapolated properly.
* The `sum` function aggregates all the responses/requests by job.
* The whole query queries the derived ratio of total number of HTTP responses that were successful and the total number of HTTP requests regardless of status.

## SLO Rationale

Glitchtip is expected to be available 95% of the time. This is based on the [load tests](../sops/load-testing.md) performed on staging.
This is a low bar estimation and can be re-evaluated once the service is running in production and performance tests are done for a longer
period of time.

## Alerts

The following are the multi-window, multi-burn-rate alerts that are associated with this SLO.

- ErrorBudgetBurn
