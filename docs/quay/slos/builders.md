# Builder SLOs

### SLI description
Success rate for builds on quay.io is tracked as a ratio of successful builds over the total number of builds.
Time a build spends waiting in the build queue is also recorded as a raw value.

### SLI rationale
Builds are an important feature of quay.io and should be reported on.

### Implementation details
Metrics are scraped from quay.io by Prometheus.

### SLO rationale
TBD
