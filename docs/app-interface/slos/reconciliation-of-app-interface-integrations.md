# Reconciliation time of app-interface integrations

## SLI description

We're measuring the elapsed time between the time to merge in app-interface and the modifying cluster operations, e.g the time it takes between a ConfigMap is updated in app-interface up to the time that the changes are applied. We want that a certain target of those fall under 20 minutes.

## SLI Rationale

Gitops via app-interface is one of our main offerings as app-sre. This SLI codifies directly the user experience as low reconciliation times are a sign of health in all the different components in our pipelines:

* Jenkins jobs transforming the contents of app-interface in a JSON bundle
* The bundle being uploaded to S3
* The bundle being served correctly by qontract-server
* The integrations running properly
* The clusters being healthy

## Implementation details

We use the `qontract_reconcile_function_elapsed_seconds_since_bundle_commit` set of histogram metrics as the base for this SLO.

In order to populate this histogram, we have instrumented our code to calculate the time between the bundle creation and the modifying operations. A few considerations about this process:

* We have forced the creation of a merge commit in app-interface to accurately reflect the commit merge timestamp
* We have implemented a mechanism to avoid that certain objects count into the histogram via the `qontract.ignore_reconcile_time` annotation. These are the objects that can be updated in Vault which will trigger a modification in the cluster that does not correspond to a merge
* Since integrations may take several minutes to run, we can be underestimating the time to merge as we can have multiple merges while the integrations run.
* We may need to inject traffic (commits to app-interface) if we see that we don't have enough data

A final note: we're not taking into account the modifications that come from saas files as those are made in the Jenkins nodes, that are one shot processes.

## SLO Rationale

We acknowledge that 20 minutes may seem as a long time for a reconciliation process but for the moment it models well the expectations of the tenants and it helps us not overcommitting. We strive for a high percentage of our reconciliations to fall under 20 minutes and this should be reviewed to make it higher as soon as we gain confidence.

## Alerts

There are no alerts associated to this SLO yet. We still are in an analysis phase, making sure that we are correctly measuring.

We will need to adjust our burn rates windows to make sure to make sure we have enough datapoints to feed the expressions.
