# Assisted Installer SLOs


## Service Overview

The Assisted Installer Service assists users to install OpenShift using bare metal machines.

The service runs on cloud and user/agent actions are done via a REST API.

The service contains the states of all user’s clusters.

## SLIs and SLOs

| | SLI | SLO |
|:-------------:|:-------------|:-------------:|
| Liveness | The liveness of the pods that serve the service.<br /><br />All pods down for at least 5m is considered a failure. | No failures |
