# Add route for CRDA component

## Background

The AppSRE team is running CodeReady Analytics services which are routed to via openshift.io:
- *.openshift.io
- *.api.openshift.io
- *.prod-preview.openshift.io
- *.api.prod-preview.openshift.io

## Purpose

This SOP explains how to set up routes for such services.

## Content

1. Create an OHSS ticket to add a DNS entry. The entry will be of the form <service-name>[.prod-preview][.api].openshift.io. Request that the DNS entry will be created as a CNAME pointing at the cluster's ELB:
    * stage: elb.apps.app-sre-stage-0.e9a2.p1.openshiftapps.com ([app-sre-stage-02](/data/openshift/app-sre-stage-02/cluster.yml))
    * production: elb.apps.app-sre-prod-03.z5a2.p1.openshiftapps.com ([app-sre-prod-03](/data/openshift/app-sre-prod-03/cluster.yml))
1. Create a Route in the service's namespace with the matching host from the previous step and reference the route from the namespace file.
    * Example: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/dsaas/bayesian-production/bayesian-osa-api.route.yaml
