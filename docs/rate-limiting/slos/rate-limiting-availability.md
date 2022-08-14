# Rate Limiting  - Availability SLO/SLI

## SLI description

We are measuring the proportion of requests that weren't served successfully against the total requests. 

## SLI Rationale

As an important part of OCM ecosystem, rate limiting is expected to provide reliable responses and be available.
## Implementation details

We're measuring the failed requests when calling the rate-limiting service and divide it by the total of all the API requests made. 
The number of failed requests are measured at the Envoys level using the `envoy_cluster_ratelimit_failure_mode_allowed` metric. This [metrics](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/rate_limit_filter#statistics) is valid when `failure_mode_denied` set to `false`, for example: kas-fleet-manager Envoy [setting](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/services/managed-services/production/kas-fleet-manager-envoy.configmap.yaml#L201). 
Total request number is measured by adding envoy_cluster_ratelimit_failure_mode_allowed, authorized_calls and limited_calls. Those are custom metrics impelmented by Limitador [itself](https://github.com/Kuadrant/limitador/blob/main/limitador/src/prometheus_metrics.rs#L12) that measure the total calls that were authorized and limited.

## SLO Rationale

Rate limiting is expected to be available 99.9 percent of the time. The reason for such high availability requirements is due to that
rate limiting is an important component in the OCM ecosystem which backend services rely on.
If Rate Limiting is not available the backend service run a risk of resource exhaustion.
The target is 99.9 percent of the requests gets evaluated to check if it need to be throttled. This also indicate the 0.1 percent error budget for a 28 day window.

## Alerting

Following are the list of alerts that are associated with this SLO

- RateLimitingUnavailable
  - **Severity:** high
  - **Potential Customer Impact:** medium 
- RatelimitingErrorRateHigh
  - **Severity:** high
  - **Potential Customer Impact:** medium
