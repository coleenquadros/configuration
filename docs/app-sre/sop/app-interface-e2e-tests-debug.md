# e2e tests Job debugging

## Background

The app-interface e2e tests is executing the following tests: [link](/hack/e2e_tests.sh)

## Purpose

This is an SOP for failure of the app-interface e2e tests job.

## Content

If this job fails, it means that one of the tests is failing:

- `create-namespace` - the test could either not create a new namespace or the namespace was created without the correct `RoleBinding`s.
- `dedicated-admin-rolebindings` - the test could not find the correct `RoleBinding`s in a certain namespace(s).

This would usually mean that we should open a SNOW ticket to OpenShift SRE:
https://url.corp.redhat.com/OpenShift-SRE-Service-Request-Form

* `Request Type` - Incident/Outage
* `Customer Type` - v3 Dedicated Clusters (Internal and Partner customers)
* `Incident severity 1-4` - 1 - Urgent (as this may influence other clusters as well)
