# Design doc: Jenkins Worker Fleet

## Author/date

Feng Huang / 2022-12-05

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-6701

## Background

There are 3 issues I found using Jenkins EC2 Fleet plugin.  

First, the Jenkins EC2 Fleet plugin allows us to add an existing ASG as Jenkins worker nodes via [UI](https://ci.int.devshift.net/manage/configureClouds/). Due to some front-end issue(update: fixed by [MR](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/542)) of our ci controller, we can only config the fleet via [groovy script](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ci-int-jenkins-worker.groovy#L228-304). Both ways are manual processes and lack of state track and automation. Most people are not familiar with groovy scripts and afraid to run them [e.g](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/52713#note_5374053). There is also no way to check what would change before applying the script.

Second, there are conflicts between using terraform and the EC2 Fleet plugin to manage ASGs simultaneously, especially when adjusting the size. As long as the plugin is running, an update function is called every 15 seconds to sync the state of the plugin with the state of ASG. This means when we need to adjust the minSize or maxSize of the ASGs via terraform resources, the plugin would want to change it back and vice-versa. Terraform and groovy would fight with each other during the size is different on each side, scaling up and down ASGs again and again.

Third, The plugin handles the termination of instances based on idle period settings. If there are more nodes than minSize and either a node has been idle for longer than Max Idle Minutes Before Scaledown or there are more nodes than allowed by maxSize, the idle node will be scheduled for termination. Without [scale-in protection](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-instance-protection.html) instances could be terminated unexpectedly by external conditions and running jobs could be interrupted. Meanwhile, none of the [termination policies](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-termination-policies.html) provided by ASG depends on the workload of the instances. 

As a result, the plugin would keep enabling scale-in protection on ASGs even if we disable it via terraform. However, scale-in protection will block instance refresh when we need to update configuration such as tags or AMIs for all instances. We could add simple automation here to disable scale-in protection on existing instances (instead of disabling it on ASGs so the plugin is still happy) when there is a pending instance refresh on ASG. It would just be a few AWS API calls.

### Proposal

Enhance the Jenkins Instance schema with a new section called `workerFleets`. This section will be placed in the source Jenkins Instance and will contain the configuration for Jenkins worker nodes:

```yaml
workerFleets:
- identifier: ci-int-jenkins-worker-app-interface
  account:
    $ref: /aws/app-sre/account.yml
  namespace:
    $ref: /services/app-sre/namespaces/app-sre-ci.yaml
  labelString: app-interface
  numExecutors: 2
  idleMinutes: 30 # optional
  minSpareSize: 0 # optional
  noDelayProvision: true # optional, disabled by default. 
- identifier: ci-int-jenkins-worker-app-sre
  account:
    $ref: /aws/app-sre/account.yml
  namespace:
    $ref: /services/app-sre/namespaces/app-sre-ci.yaml
  labelString: app-sre app-interface-long-running managed-services osde2e qe quarkus service-registry
  numExecutors: 3
```

This schema change will be picked up by the integration responsible for applying the new configuration against Jenkins Instance.

minSize and maxSize need to come from ASG configuration to avoid conflict. [e.g.](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/namespaces/app-sre-ci.yaml#L100-101)

### Implementation

JCasC(Jenkins Configuration as Code) contains cloud config. We can use [Export](https://ci.int.devshift.net/manage/configuration-as-code/export) endpoint to get existing config and [Apply](https://ci.int.devshift.net/manage/configuration-as-code/apply) endpoint to update cloud config.

```yaml
jenkins:
  clouds:
  - eC2Fleet:
      addNodeOnlyIfRunning: true
      alwaysReconnect: false
      cloudStatusIntervalSec: 10
      computerConnector:
        sSHConnector:
          credentialsId: "jenkins"
          launchTimeoutSeconds: 60
          maxNumRetries: 0
          port: 22
          retryWaitTime: 0
          sshHostKeyVerificationStrategy: "nonVerifyingKeyVerificationStrategy"
      disableTaskResubmit: false
      fleet: "ci-int-jenkins-worker-app-interface"
      fsRoot: "/var/lib/jenkins"
      idleMinutes: 30
      initOnlineCheckIntervalSec: 15
      initOnlineTimeoutSec: 300
      labelString: "app-interface"
      maxSize: 9
      maxTotalUses: -1
      minSize: 6
      minSpareSize: 0
      name: "ci-int-jenkins-worker-app-interface"
      noDelayProvision: true
      numExecutors: 2
      oldId: "c6614118-b5dd-412d-bbb0-3b84a9dd9ac1"
      privateIpUsed: true
      region: "us-east-1"
      restrictUsage: true
      scaleExecutorsByWeight: false
```

This integration will pick up graphql info from APP-Interface, assemble the YAML file, compare it with the export config and apply it if there is a change. The integration will only manage the `clouds` part of JCasC and won't affect other configs. Meanwhile, We could reuse this pattern to support handling all kinds of config in JCasC and make all Jenkins config part of APP-Interface.

## Milestones

* [ ] Milestone 1 - Implement JCasC integration 
* [ ] Milestone 2 - Enable instances refresh
