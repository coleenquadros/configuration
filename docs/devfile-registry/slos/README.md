# Devfile Registry and Red Hat Devfile Registry SLOs

## Service Overview

The Devfile Registry and Red Hat Devfile Registry services provide devfile stacks and samples to users and developer tools.

The service runs on OSD and user/agent actions are done via the web browser, or through client libraries in developer tools.

## SLIs and SLOs

| | SLI | SLO |
|:-------------:|:-------------|:-------------:|
| Availability | The proportion of successful requests to the devfile registry and OCI registry server.<br /><br />Any HTTP status other than 500–599 is considered successful.<br /><br /># API requests which do not have a 5XX status code<br />/<br /># API requests | 90% success |
| Latency | The proportion of sufficiently fast requests to the devfile registry server.<br /><br />"Sufficiently fast" is defined as < 0.5 sec.<br /><br /># Successful API requests with a duration less than [0.5s]<br />/<br /># Successful API requests | 90% of requests are "Sufficiently fast" |
| Latency | The proportion of sufficiently fast requests to the oci registry server.<br /><br />"Sufficiently fast" is defined as < 2 sec.<br /><br /># Successful API requests with a duration less than [2s]<br />/<br /># Successful API requests | 90% of requests are "Sufficiently fast" |
