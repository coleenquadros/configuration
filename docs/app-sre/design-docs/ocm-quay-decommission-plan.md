# Design doc: OCM-Quay Decommission plan

## Author/date
`jfchevrette` / `2023-04-27` 

## Tracking JIRA
https://issues.redhat.com/browse/SDE-2715

## Problem Statement
OCM-Quay is an environment which was provisioned in April 2021 following multiple instability events with quay.io with the goal of providing a second fallback registry to provide OpenShift images for OSD clusters during install and upgrade. Quay.io stability and reliability has improved tremendously since then.

Red Hat has a compelling interest in shutting down the ocm-quays, as they are quite expensive, and are also a support burden.

One challenge is that some customers are depending on the ocm-quay registry because they have blocked quay.io in their AWS accounts per their own policies (customers don't want to allow the entirety of quay.io)

## Goals
* Decommission the ocm-quay clusters and AWS resources
* Maintain the ocm-quay image pull service (pull.q1w2.quay.rhcloud.com) for clusters that have it configured in their ICSP (ImageContentSourcePolicy) configs
    * Customers who are blocking quay.io
    * Customers who may have added it in their firewall configs as per [our documentation](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-aws-prereqs.html)
* The solution must be cost-effective

## Non-objectives

## Proposal
A new ALB will be added in front of quay.io which will contain a specific set of ALB rules. Those ALB rules will have conditions that apply only to the ocm-quay hostname and specific registry URIs that we want to allow. With this, any request that come in to that hostname and to those allowed URIs will be forwarded to the quay.io pods and any other will receive a 401 Unauthorized response. Other requests targetting quay.io will remain unaffected.

The 401 Unauthorized response will need to adhere the container registry specs such that clients will not break. The spec is described [here](https://docs.docker.com/registry/spec/api/#errors). This has already been implemented and tested as part of the POC

This ALB configuration & rules have already been tested and validated in a POC. The definition can be seen [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/d65d9d6d74a3dc5339767cf86f2adb9daff26d3e/data/services/quayio/namespaces/quayp04ue2.yml#L184-212)

Access to the openshift images on the ocm-quay mirror is currently done via a unique pull secret (`openshift-release-dev+pull`) that is pushed to OSD clusters as install time by hive. This pull secret (more specifically the token) will need to be copied to quay.io in the same org (`openshift-release-dev`). We have confirmed that such a bot user does NOT already exist in quay.io. In order to do this, Quay.io engineers will need to assist in inserting the token into the quay.io database as users do not have the ability to manually set a token value.

The CDN host (`cdn01.q1w2.quay.rhcloud.com`) will be configured in quay.io's [quay-config-secret](https://gitlab.cee.redhat.com/service/app-interface/-/blob/8289e26a4945c97be85cc688a9bd1d1a96aa2d5e/resources/quay-p/quay/quay-config.secret.yaml#L311) such that it is returned whenever quay.io is being accessed via the ocm-quay hostname. The CDN host will need to be appended to quay.io's CloudFront such that it can serve the image payloads. Quay.io's team will assist in setting this up.

All this will be validated by provisioning an OSD cluster using the test/POC hostname (`pull.q1w2.quay.devshift.net`). Upon completion of the cluster install we will have validated that the plan works

Finally once everything is validated, a DNS change will be made to point the hosts from their current ALB to the new ocm-quay ALB in front of quay.io
* pull.q1w2.quay.rhcloud.com
* cdn01.q1w2.quay.rhcloud.com

Once the migration is complete, we will remove the [mirroring configs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ocm-quay/openshift-release-dev.yml) and decommission the 4 clusters and AWS resources

**Though not part of this design doc:** OSD is planning to sunset this registry endpoint in favor of registry.redhat.io. They are also evaluating the possibility of retroactively update clusters ICSP configs to remove ocm-quay and add registry.redhat.io

## Alternatives considered
* N/A - This work is the concrete implementation of the high level proposal which had already been discussed and agree upon between stakeholders

## Milestones
* See the [migration document](https://docs.google.com/document/d/1TuSGWCcmtRO2XACtfQVs55vw5VASgWihnpe1KqI4SCs/edit#)
