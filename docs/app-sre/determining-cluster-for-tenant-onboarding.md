# Guidelines to determine which cluster to use during new tenant onboarding

The objective of this document is to help appSRE member to determine which cluster to use for new tenant service. This step should be done at the early stages of onboarding when we discuss onboarding questionnaire and before we start with self-service stage for the tenant.


## Guidelines

- Most services will live under app-sre-[stage|production]-XX or appsre[sp]XX clusters
- Services for cloud.redhat.com (ak CloudDot, ConsoleDot, CRC) will live under crc[sp]XX.
- Services that require dedicated resources will have their own clusters. For e.g telemeter and quay.io have their own dedicated clusters.



If a cluster determined through above guidelines is unable to satisfy resource capacity request (not applicable in case of dedicated cluster), then we may have to scale the cluster or create a new cluster. This will require further discussion with the appropriate stakeholders.