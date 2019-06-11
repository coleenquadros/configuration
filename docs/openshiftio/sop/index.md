# Alerts

## OnlineRegistrationExporterDown

**Description:** Prometheus is unable to scrape the Online-Registration exporter.

**Impact:** Prometheus will stop reporting the OSIO clusters capacity. Graphs and dashboards are affected as well as all some alerts around OSIO cluster capacity.

**Troubleshooting:**
- Verify that the exporter deployment in the `app-sre-observability` namespace of the `app-sre` cluster.
- Manually run prometheus queries to see if there is data
    - `onlinereg_subscriber_limit`
    - `onlinereg_hidden`

## OSIOClusterCapacityLow

**Description:** Cluster capacity is low on the OSIO starter clusters. Capacity is managed via the online registration app (owned SD-A) at https://manage.openshift.com

**Impact:** No immediate impact

**Troubleshooting:**

See [OSIOClusterCapacityFull](#OSIOClusterCapacityFull)

**Resolution:**

See [OSIOClusterCapacityFull](#OSIOClusterCapacityFull)

## OSIOClusterCapacityFull

**Description:** No more remaining capacity on the OSIO starter clusters. Capacity is managed via the online registration app (owned SD-A) at https://manage.openshift.com

**Impact:** No new OSIO user accounts can be created. New accounts are queued in the registration app.

**Troubleshooting:**

- Verify [OSIO capacity graphs](https://grafana.app-sre.devshift.net/d/osio_capacity/osio-capacity?orgId=1) in grafana
- Determine if this is normal usage
    - Consult with OSIO
    - Verify cluster namespaces, look for odd patterns that would indicate abuse, miners, etc..

**Resolution:**

- Lower utilization by terminating fraudulent accounts, abuse, etc..
- Raise capacity for clusters where enough resources are available. This can be done at https://manage.openshift.com
- Provision a new OSIO cluster (net new capacity)
- 

**More info:** https://gitlab.cee.redhat.com/service/app-interface/tree/master/docs/app-sre/sop/osio-registration-app-capacity-limits.md
