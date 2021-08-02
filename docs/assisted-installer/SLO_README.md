# Assisted Installer SLOs


## Service Overview

The Assisted Installer Service assists users to install OpenShift using bare metal machines.

The service runs on cloud and user/agent actions are done via a REST API.

The service contains the states of all user’s clusters.

## SLIs and SLOs

| | SLI | SLO |
|:-------------:|:-------------|:-------------:|
| Availability | The proportion of successful requests.<br /><br />Any HTTP status other than 500–599 is considered successful.<br /><br /># API requests which do not have a 5XX status code<br />/<br /># API requests | 85% success |
| Latency | The proportion of sufficiently fast requests.<br /><br />"Sufficiently fast" is defined as < 1 sec.<br /><br /># Successful API requests with a duration less than [1s]<br />/<br /># Successful API requests | 99% of requests are "Sufficiently fast" |
