# Architecture of the service

## Cloud

* Assisted Installer REST API (backend service) - contains several go-routines, mainly:
    * The REST API service, invoked by both users and agents.
    * Monitors that periodically calculate the correct cluster and host statuses and update them when necessary.
    * Monitor to delete expired images (one hour after creation).
* Assisted Installer UI, integrated with OCM
* External components:
    * Postgres DB for storing metadata.
    * AWS S3 for storing ISOs and rendered files (currently using the open-source version of Scality for dev/test).
    * AMS is contacted for authorization.

* Agent - runs on-prem on each server.
* Assisted controller - a job that runs on a newly-created cluster that approves nodes and reports final progress to the assisted service (needed because after all hosts boot from disk there are no agents running).

* Storage units
    * Postgres DB - stores all the users data, such as: clusters, hosts & events. The data is displayed in the OCM UI.
                     If someone will delete the DB - we can restore it from RDS snapshots and if not - the user will not see his installed clusters but he can install new cluster.
                     We now delete all data for a cluster which is inactive for 3 weeks. 
        
    * AWS buckets
        * public - The public bucket has images related to specific versions that Assisted supports.  
                     This is changed infrequently, no retention for it. If the images will be deleted from this bucket - The service automatically generates the needed objects when it starts up. 
        
        * private - We are saving sensitive data such as iso + pull secrets and kubeconfig files. Users generate ISOs.  The ISO contains the user's pull-secret which is used for authentication.  In addition, each installed cluster has its kubeconfig stored so that the user can download it.
                      We now delete all data for a cluster which is inactive for 3 weeks.

* Total disaster and recovery - In case of total disaster such as: DB or bucket deletion - the service automatically generates the DB & images. If the user started installation before the disaster - it will continue but the user won't be able to see it in the UI. However, the user can run a new cluster installation after the service will recover.    
 
More data about architecture & design can be found in the [Assisted Installer HLD](https://docs.google.com/document/d/1jxNMTlotmJ0GFZ1GUEQ3hfOOVLzMT6mvY8Ufo5RdErY/edit) document


## app-interface files location

https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/assisted-installer


## Environments

There are 3 environments:
* Integration
* Staging
* production

Environments namespaces & configuration are located at: 
https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/assisted-installer/namespaces


## Workflows

High-level API flow

* [user] `POST /clusters/` : Creates a cluster resource with minimal information.
* [user] `POST /clusters/{clusterId}/downloads/image`: Generates per-cluster ISO from service, providing optional proxy information.
The service generates an ISO upon request and stores in S3.  The object will be set to expire after 4 hours.
* [user] `GET /clusters/{clusterId}/downloads/image` : Downloads per-cluster ISO from service.
* [user] `PATCH /clusters/{clusterId}` : Updates cluster resource with any additional information required to create the cluster (this can be done any time before installation begins).
* [agent] `POST /clusters/{clusterId}/hosts` : Each host agent registers itself with the API service, providing its host ID (based on motherboard serial).
* [agent] `GET /clusters/{clusterId}/hosts/{hostId}/instructions` : Each host agent retrieves the next steps that it must execute to progress in the discovery and installation (agent calls this at a fixed interval to continuously retrieve instructions, also acts as a heartbeat).
* [agent] `POST /clusters/{clusterId}/hosts/{hostId}/instructions` : Host submits results for a completed step
* [user] `POST /clusters/{clusterId}/actions/install` : User initiates installation (after discovery has completed and nodes meet minimum requirements).  This is an async operation and the user can poll on the cluster resource to view progress.
* [user] `GET /clusters/{clusterId}/downloads/kubeconfig` : Once the installation has completed, the user can download the cluster’s kubeconfig.


## Pipelines

### Service deployment file for all environments:

https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/assisted-installer/cicd/saas.yaml

### Post deployment job:

The post deployment job runs cluster installation using the assisted-service and verifies that the installation is finished successfully.

https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/assisted-installer/cicd/saas-post-deploy.yaml 

### Monitoring for staging & production:

https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/assisted-installer/cicd/saas-monitoring.yaml


## API description

Check the endpoint:
* Stage: curl https://api.stage.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"
* Production: curl https://api.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"

If service is up you should get a list of clusters, might be [] if you never created any clusters.

You can also check the assisted-service using the UI:
* Stage: https://qaprodauth.cloud.redhat.com/openshift/assisted-installer/clusters/?env=staging 
* Production: https://console.redhat.com/openshift/assisted-installer/clusters 

You should see the list of clusters that you created and you can create a new cluster to make sure that the service is functioning properly.

