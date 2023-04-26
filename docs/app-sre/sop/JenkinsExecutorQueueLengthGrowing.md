# JenkinsExecutorQueueLengthGrowing

## Severity: Critical FTS

## Impact

* Jobs for a node type are not being executed fast enough,

## Summary

* Jobs are being queued in a certain node type a higher rate than they're being executed.

## Access required

* Access to Jenkins instance.
* app-interface merge rights.
* AWS app-sre account.

## Steps

We need to determine if we have a capacity problem or there are nodes that are not available to Jenkins.

* In Jenkins UI, go to Manage Jenkins > Manage Node and clouds.
* Check if the nodes of the affected node type (they will have the `-{node-type}`) are available to Jenkins.
* Check if the nodes of the node type are actually serving jobs.
  * If the nodes are serving jobs, then we don't have enough capacity. It can be increased in the ASG configuration in `data/services/app-sre/namespaces/app-sre-ci.yaml`
    * The configuration section will have an `identifier` that matches the node name.
  * If the nodes of the node type are not serving jobs, most likely it is a AWS problem. The node is not working fine or it is not reachable. In order to speed up recovery it can be terminated (the AWS instance id is part of the node name) and it will be recreated by the ASG.
