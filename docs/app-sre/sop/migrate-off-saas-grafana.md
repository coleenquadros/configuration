# Migrate off saas-grafana saas file

[TOC]

## Introduction

[saas-grafana.yaml](/data/services/observability/cicd/saas/saas-grafana.yaml) was introduced to remove the Grafana Dashboards configmaps from app-interface, speeding up development process using grafana staging while controlling from AppSRE the production promotion. The pattern didn't scale properly and we have since recommended app-interface users to manage their dashboards via saas files they own as any other piece of software of the service.

saas-grafana has now been officially [deprecated](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/47030) and tenants are expected to move their dashboard deployments off of it creating a single MR with the instructions that will follow.

An full example of a MR that migrates one service dashboards to its own saas file can be found in https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/47052

### Create a new saas file

The new saas file will contain the `resourceTemplates` sections that are associated to your service's dahsboards. Pay attention to the following aspects:

* `name` has to be unique and shorter than 40 characters.
* Use the appropriate refs to the `app`, `pipelinesProvider` and `slack` fields using the corresponding for your service.

### Delete the resource templates from saas-grafana

So they are managed only by one saas file.

### Assign ownership of the newly created saas file

Using one of your service's roles.

### and enjoy the power of owning the deployment cycle of your dashboards

## Further readings

* [Visualization with Grafana](/docs/app-sre/monitoring.md#visualization-with-grafana)
* [Continuous Delivery in app-interface](/docs/app-sre/continuous-delivery-in-app-interface.md)
