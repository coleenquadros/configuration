# Guidelines to determine which cluster to use during new tenant onboarding

The objective of this document is to help appSRE member to determine which cluster to use for new tenant service. This step should be done at the early stages of onboarding when we discuss onboarding questionnaire and before we start with self-service stage for the tenant.


## Guidelines



- We try to put most services under api.openshift.com or under console.redhat.com
    * if a service is a component under api.openshift.com, it should be deployed in app-sre-[stage|production]-XX or appsre[sp]XX
    * if a service is a component under console.redhat.com, it should be deployed in crcsXXue1

    XX represents a number  01, 02 etc.
- Services that require dedicated resources will have their own clusters. For e.g telemeter and quay.io have their own dedicated clusters.



If a cluster determined through above guidelines is unable to satisfy resource capacity request (not applicable in case of dedicated cluster), then we may have to scale the cluster or create a new cluster. This will require further discussion with the appropriate stakeholders.
