# Quarkus Registry SLOs


## Service Overview

The Quarkus Extension Registry service provides a centralized place for tooling to query for extensions and platforms. 

The service runs on cloud and user/agent actions are done via a REST API.

## SLIs and SLOs

| | SLI | SLO |
|:-------------:|:-------------|:-------------:|
| Availability | The proportion of successful requests.<br /><br />Any HTTP status other than 500–599 is considered successful.<br /><br /># API requests which do not have a 5XX status code<br />/<br /># API requests | 85% success |
| Latency | The proportion of sufficiently fast requests.<br /><br />"Sufficiently fast" is defined as < 1 sec.<br /><br /># Successful API requests with a duration less than [1s]<br />/<br /># Successful API requests | 90% of requests are "Sufficiently fast" |

### SOPs
* [Low Availability](./sops/quarkus-registry-availability.md)
* [High Latency](./sops/quarkus-registry-latency.md)
