# Add route for OCM component

## Background

The AppSRE team is onboarding services which are routed to via api.openshift.com. Examples: Cincinnati, Assisted-installer, KAS Fleet manager.

## Purpose

This SOP explains how to set up routing for such services using the OCM gateway.

## Content

1. Create an OHSS ticket to add a DNS entry. The entry will be of the form <random lower case and digits of length 15>[.stage].api.openshift.com.
    * Examples:
        - Cincinnati stage: https://cc533os557xkwku.api.stage.openshift.com
        - Cincinnati production: https://ynkpvft2b33mrat.api.openshift.com
    Examples OHSS ticket: https://issues.redhat.com/browse/OHSS-1370
1. Create a Route in the service's namespace with the matching host from the previous step and reference the route from the namespace file.
    * Example: https://gitlab.cee.redhat.com/service/app-interface/-/blob/ec4454ece6a0f975f0239422f2090d2d1670c5e8/resources/app-sre/cincinnati-production/cincinnati.route.yaml
1. Add an entry in the OCM gateway configuration to perform this routing.
    * Example: https://gitlab.cee.redhat.com/service/app-interface/-/blob/ec4454ece6a0f975f0239422f2090d2d1670c5e8/resources/services/ocm/production/gateway.configmap.yaml#L43-50
