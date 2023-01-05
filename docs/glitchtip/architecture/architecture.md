## Glitchtip architecture


### Service Description

Glitchtip is An Open source Error tracking software and a upstream fork of Sentry. The staging environment is available via https://glitchtip.stage.devshift.net and the production environment is in available via https://glitchtip.devshift.net

## The Architecture

Glitchtip's front-end is written in Angular js and Node JS, along with some typescript and It's backend is written in python Django, It uses PostgreSQL as its backend database and Redis for a caching layer.

## Features

 * [Error Tracking](https://glitchtip.com/documentation/error-tracking) 
 * [Organization and Project Management](https://glitchtip.com/documentation/uptime-monitoring)
 * [Sentry Client Integration](https://glitchtip.com/sdkdocs)
 * [Application Performance Monitoring]() 
 * [Uptime Monitoring](https://glitchtip.com/documentation/uptime-monitoring) 
 * [Integrations](https://glitchtip.com/documentation/integrations)


## Main Components:

1. The `Beat` Deployment - Is responsible for the initial database migration and celery scheduling to the worker nodes.

2. The `Web` Deployment - Is responsible for hosting the Web UI and interface.

3. The `Worker` Deployment - Is responsible for scheduling worker node tasks via the celery jobs spawn via the beat pods.

## Introduction 
- This is a diagram provides a high level overview of the Glitchtip Architecture both from a Openshift / Kubernetes perspective and external entities it interacts with such as AWS RDS Potgres and AWS Elacticache. 


![Glitchtip](images/Glitchtiparchitecture1.png)

**Note:** This Diagram will need to be updated once onboarding is completed.

## Platform Architecture and Transparency

- User data is stored in Postgres AWS RDS service for both `stating` and `production` environments.
- This includes error data as sent by the Sentry SDK. Glitchtip data is configured to be purged every 30 days.

## Resource consumption

- The staging instance of Glitchtip consumes about 96MiB of memory and 0.01 CPU for the `beat` pod component,  when nothing is happening. 

    - The database instance that is currently used in stage is db.t3.micro. Its CPU utilization is about
    5% on average and 30% during the load test. The production instance is db.t3.small.
    The S3 bucket space consumed is almost none at the moment but will grow as the Glitchtip service will start being used. The
    space is occupied only by the attachments uploaded by the users. Therefore we do not expect a dramatic change.
	
- The production instance of Glitchtip has 2 instances of "worker" and "web" components with similar requirements. We estimate that when the service gets used the resource consumption could approach the value
seen in the load test occasionally, scaling the components is the best strategy if the resource consumption exceeds the estimation.

### Resource consumption for glitchtip components
#### Resource consumption for beat deployment
Resource Usage for beat deployment for 30 days time period
##### CPU cores Usage
![glitchtip-beat-cpu-cores-usage](images/glitchtip-beat-cpu-cores-usage.png)

##### Memory Usage
![glitchtip-beat--memory](images/glitchtip-beat-memory.png)

#### Resource consumption for worker deployment
Resource Usage for worker deployment for 30 days time period
##### CPU cores Usage
![glitchtip-worker-cpu-cores-usage](images/glitchtip-worker-cpu-cores.png)

##### Memory Usage
![glitchtip-worker-memory](images/glitchtip-worker-memory.png)

#### Resource consumption for web deployment
Resource Usage for web deployment for 30 days time period
##### CPU cores Usage
![glitchtip-web-cpu-cores-usage](images/glitchtip-web-cpu-cores.png)

##### Memory Usage
![glitchtip-web-memory](images/glitchtip-web-memory.png)

## Load Testing
The load testing on stage environment is available at: [Load Testing Document](../sops/load-testing.md)
