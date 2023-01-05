# Git Partition Sync - Architecture

## Service Description

## Components
Git Partition Sync is comprised of two components: `producer` and `consumer`

### Producer
`producer` is tasked with cloning, tarring, encrypting, and uploading specified GitLab repositories to s3. `producer` formats the keys of uploaded objects as base64 encoded json for processing by `consumer`.  
`producer` is solely deployed to `appsrep05ue1` 

### Consumer
`consumer` is tasked with downloading, decrypting, untarring, and pushing GitLab repositories to desired targets.  
`consumer` is soley deployed within FedRamp environment.

## Routes
None

## Dependencies
Git Partition Sync cannot function if any of the following systems are inaccessible:
* https://app-interface.devshift.net
* https://gitlab.cee.redhat.com
* `git-partition-sync` S3 bucket (located within app-sre account)

## Service Diagram
![Git Partition Sync Architecture Diagram](arch.png)

## Application Success Criteria
Git Partition Sync is successful if all updates to specified GitLab repositories within source GitLab instance are mirrored to their counterparts within destination GitLab instance.

Broken down by component:
* `producer` is successful if it consistently detects updates to source projects and uploads the latest versions of the repositories to s3
* `consumer` is successful if it consistently detects updates to s3 objects(repo tars) and pushes latest versions to destination projects

## State
Git Partition Sync relies on the desired state within App-Interface. Specifically, the `gitlabSync` attribute, defined within `codeComponents`. Additionally, `producer` ensures latest versions of source projects are within s3.

## Load Testing
N/A

## Capacity
`producer` clones source projects to local filesystem for tarring/encrypting.  
`consumer` downloads s3 objects and untars/decrypts the repository objects within local filesystem.  
  
For both `producer` and `consumer`, the local directories where this work is performed should be cleared automatically. However, if there is a non-obvious issue with either component, check the size of container's filesystem.  
