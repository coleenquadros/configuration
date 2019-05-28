# Troubleshooting Jenkins metrics

We use the Prometheus plugin for Jenkins

Prometheus is configured to scrape the /prometheus endpoint on jenkins by supplying basic auth for the `OPS-QE-JENKINS-CI-AUTOMATION` user

Troubleshooting steps:

- Check the creds being used to scrape jenkins. These are in vault.
    - ci.int: https://vault.devshift.net/ui/vault/secrets/app-sre/show/ansible/host_vars/prometheus.centralci.devshift.net
    - ci.ext: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-prometheus/prometheus/prometheus-app-sre-additional-scrapeconfig

- Validate that the user has permissions on the `Metrics` group in Jenkins.
    - If it doesn't have the permissions, add them and 'Safely restart' Jenkins.
