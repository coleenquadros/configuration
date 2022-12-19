# AppSRE Runbooks

This page is intended to be a single location that AppSRE engineers can bookmark for easy access to runbooks. These runbooks should cover common technologies that AppSRE interacts with on a regular basis, examples includes AWS RDS, Jenkins, GitLab, or OpenShift.

**What are runbooks?**

A runbook is a compilation of information that is useful for running a service in production. This is intentionally vague because teams may find many useful sections to include in runbooks such as overviews of the technology, SOPs, troubleshooting information, escalation paths, known issues, and more. The intent is to make it easier for an engineer, with limited experience with a technology, to respond to issues.

### General

This is the place for all runbooks that don't have their own category.

* [Cloudflare](/docs/app-sre/runbook/cloudflare.md)
* [gitlab.cee.redhat.com](/docs/app-sre/runbook/gitlab-cee-redhat-com.md)

### Qontract Integrations
* [Dyn Traffic Director](/docs/app-sre/runbook/integration-dyn-traffic-director.md)

### OpenShift
* [Ingress Routers](/docs/app-sre/runbook/openshift-ingress-routers.md)
* [Cert Manager Operator](/docs/app-sre/runbook/cert-manager.md)

### AWS
* [RDS (Relational Database Service)](/docs/aws/runbook/aws-rds.md)

### Jenkins
* [General Runbook](/docs/app-sre/runbook/jenkins.md)
* [CI-EXT Load Balancing](/docs/app-sre/runbook/jenkins-ci.ext-waf_alb.md)
* [OS Upgrades](/docs/app-sre/runbook/jenkins-os-upgrade-workflow.md)
* [Weekly Maintenance](/docs/app-sre/runbook/jenkins-weekly-maintenance.md)
