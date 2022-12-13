# SOP : Devfile Registry

<!-- TOC depthTo:2 -->

- [SOP : Devfile Registry](#sop--devfile-registry)
    - [Verify it's working](#verify-its-working)
    - [Reporting analysis](#reporting-analysis)
    - [Reverting broken versions](#reverting-broken-versions)
    - [IndexServerHTTPLatency](#indexserverhttplatency)
    - [OCIServerHTTPLatency](#ociserverhttplatency)
    - [OCIServerErrorBudgetBurn](#ociservererrorbudgetburn)
    - [IndexServerErrorBudgetBurn](#indexservererrorbudgetburn)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Verify it's working

- At least one `devfile-registry` pod is marked as UP in Prometheus.
- The devfile registry route is serving a json file (index.json)
- Additional details on expected behaviour are available in the Devfile Registry AppSRE onboarding doc: https://docs.google.com/document/d/1euY9e6ntL5JJj8gw2dXJ3pVgHhVy_md9eYbYawexhYg/edit?ts=5fce83b1#
- Additional architecture diagrams can be found under the `docs/devfile-registry/images` folder

---

## Reporting analysis

Analysis of alerts should be reported on Slack in `#team-devfile-registry-alert`, mentioning both `@app-sre-ic` and `@team-devfile-registry` and.
In cases where that analysis is "this alert is too sensitive; this is nothing we need to worry about in the short term", the mentions are still worthwhile because they make it less likely that either team invests duplicate time in re-analyzing the same alert.

## Reverting broken versions

Production reverts can be applied via [saas-devfile-registry][], in cases where the issue is due to a production bump having pushed out broken code.
Reverting [the most-recently merged bump][saas-devfile-registry-bump] will move production back to the code it was running before.

---

## IndexServerHTTPLatency

### Summary:

The index server in the devfile registry isn't showing response times < 2 seconds 90% of the time. The index server simply serves up a simple json file from disk in the container, so very little computation is done and the response times should be much less than 2 seconds.

### Impact:

Users interacting with the registry through tools like odo or Eclipse Che will see increased delays with listing devfile stacks in the registry.. As devfile stacks are stored and retrieved on a separate container, there should be no impact to retrieving devfile stacks.

### Severity: Medium

### Access required:

- Access to the clusters that run the Devfile Registry, namespaces:
    - devfile-registry-stage (app-sre-stage-01)
    - devfile-registry-production (app-sre-prod-04)

### Steps:

- Check load on the index server container, using the [Devfile Registry Service Grafana dashboard][].
    - CPU & Memory usage, and number of requests to the server.
- High latency may require increasing the number of replicas deployed, or increasing the CPU and Memory given to the index server container
- If increasing the number of replicas, CPU, or Memory limits did not help, contact the devfile registry team.
---

## OCIServerHTTPLatency

### Summary:

The OCI registry server storing the devfile stacks is seeing increased latency, with response times > 5 seconds 10% or more of the time.

### Impact:

Users trying to retrieve devfile stacks from the registry will see an increased display that may or may not be noticeable (depending on the size of stack being retrieved, and the latency). If the latency is particularly bad, tools like Che or Odo could time out retrieving stacks.

### Severity: Medium

### Access required:

- Access to the clusters that run the Devfile Registry, namespaces:
    - devfile-registry-stage (app-sre-stage-01)
    - devfile-registry-production (app-sre-prod-04)

### Steps:

- Check load on the oci server container, using the [Devfile Registry Service Grafana dashboard][].
    - CPU & Memory usage, and number of requests to the server.
- High latency may require increasing the number of replicas deployed, or increasing the CPU and Memory given to the oci server container
- If increasing the number of replicas, CPU, or Memory limits did not help, contact the devfile registry team.

---

## OCIServerErrorBudgetBurn

### Summary:

The OCI Sever in the devfile registry has failed to meet its availability threshold (90%). 

### Impact:

If the OCI server is unavailable, then users will be completely unable to retrieve devfile stacks from the registry, breaking critical flows in projects like Eclipse Che or Odo.

### Severity: Critical

### Access required:

- Access to the clusters that run the Devfile Registry, namespaces:
    - devfile-registry-stage (app-sre-stage-01)
    - devfile-registry-production (app-sre-prod-04)

### Steps:

- Collect logs from the oci server container if possible. See if there are any error messages (should be none).
- Check load on the oci server container, using the [Devfile Registry Service Grafana dashboard][].
   - CPU & Memory usage, and number of requests to the server.
- Check number of requests to the server that ended with a 5xx error, using the [Devfile Registry Service Grafana dashboard][].
- Most likely culprits include **very** high loads on the oci server or a bad update. 
   - If very heavy load is suspected across replicas, increase the CPU/Memory limits, or # of replicas.
   - OCI server logs may provide insight on why it's not serving requests for other causes. There should be no errors in the logs for a healthy OCI server
   - If increasing CPU, Memory, or numbers of replicas did not help, and if an update was recently performed, roll back to last known good version. 
- Contact the devfile registry team if above steps to do not resolve the problem or if an update had to be rolled back.

---

## IndexServerErrorBudgetBurn

### Summary:

The Index Sever in the devfile registry has failed to meet its availability threshold (90%). 

### Impact:

If the OCI server is unavailable, then users will be completely unable to list of devfile stacks in the registry. They will still be able to pull stacks that they are aware of, but being unable to list stacks will cause a number of problems in consumers of the devfile registry.

### Severity: Critical

### Access required:

- Access to the clusters that run the Devfile Registry, namespaces:
    - devfile-registry-stage (app-sre-stage-01)
    - devfile-registry-production (app-sre-prod-04)

### Steps:

- Collect logs from the index server container if possible. There should be no errors in logs for a healthy index server.
- Check load on the index server container, using the [Devfile Registry Service Grafana dashboard][].
   - CPU & Memory usage, and number of requests to the server.
- Check number of requests to the server that ended with a 5xx error, using the [Devfile Registry Service Grafana dashboard][].
- As the index server is just a simple nginx server hosting an index.json file, the most likely culprit is a bad update was performed.
   - If very heavy load is suspected across all of its replicas, consider increasing the CPU/Memory limits or number of replicas
   - If an update was recently performed, roll back to last known good version
- Contact the devfile registry team if above steps to do not resolve the problem or if an update had to be rolled back.


## Escalations

Slack: `#forum-devfile`

Developers: `@team-devfile-registry`

Slack alerts: `#team-devfile-registry-alert`

Team email: team-devfile@redhat.com

[saas-devfile-registry]: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/devfile-registry/cicd/ci-int/saas.yaml
[saas-devfile-registry-bump]: https://gitlab.cee.redhat.com/service/app-interface/-/commits/master/data/services/devfile-registry/cicd/ci-int/saas.yaml
[Devfile Registry Service Grafana dashboard]: https://grafana.app-sre.devshift.net/d/7s_TsTsGz/devfile-registry-service?orgId=1
