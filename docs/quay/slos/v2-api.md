# v2 API SLO

### SLI description
The v2 API is used for quay's registry functionality, and success rate is 
used as an SLI.
The following endpoints are reported on as a ratio of non-5XX reponses to 
the total amount of requests.

- `GET /v2/auth`: Auth success rate
- `GET /v2/<ns>/<repo>/manifests/<tag | digest>`: Get manifest success rate
- `GET /v2/<ns>/<repo>/blobs/<digest>`: Get blob success rate
- `POST/PATCH/PUT /v2/<ns>/<repo>/blobs/upload`: Upload blob success rate
- `POST/PATCH/PUT /v2/<ns>/<repo>/manifests/tag`: Upload manifest success rate

### SLI rationale
Manifest and blob operations are critical to Quay's ability to push/pull. 
Auth operations are critical for access to private repos.

### Implementation details
Metrics are scraped from quay by Prometheus.

### SLO rationale
Users should at least be able to pull images from quay.io, so `GET` methods have 
a target SLO of 99.9%. `POST/PATCH/PUT` methods have a target of 99.5%
