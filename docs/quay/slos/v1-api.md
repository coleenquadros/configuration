# v1 API SLOs

### SLI description
The v1 API is used by quay.io's UI, and the SLIs correspond to the success rate of each endpoint.
The following endpoints are reported on as a percentage of non-5XX responses to the total number of requests.

- `GET /api/v1/user`: Listing orgs success rate
- `GET /v1/repository`: Listing repos success rate
- `GET /v1/repository`: Listing tags success rate
- `GET /api/v1/repository/<ns>/<repo>/manifest/<digest>/security`: Security
information for tag success rate

### SLI rationale
Measuring these values are necessary to ensure satisfactory user experience for quay.io.

### Implementation details
Metrics are scraped from quay.io by Prometheus.

### SLO rationale
Listing orgs, repos, and tags are important so a target of 99.5% is set for them.
The ui is still functional for the most part without security information, so a target
of 90% is set for the security endpoint

