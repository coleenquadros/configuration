# Continuous Integration and Delivery For Jenkins Worker Nodes

## Overview

Continuous Integration means building AMIs for the Jenkins worker nodes.

Continuous Delivery means deploying instances via AWS Auto Scaling groups (ASGs).

## Continuous Integration

We use the Ansible Packer provisioner to build different AMIs based on different base AMIs (we are using CentOS 7, RHEL 7, and RHEL 8) and run different roles. Packer configuration can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/packer). Each new commit [that makes changes](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/build_images.sh#L51-56) under that folder will trigger a building process for all types of worker nodes. The roles configuration for each kind of node can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/packer/ansible/jenkins-worker.yaml). To add a new type would also require adding a new source in packer [config](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/packer/worker.pkr.hcl#L40-80) 

For security, all AMIs are built in [app-sre-ci](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-ci/account.yml) account. Once the AMIs get built successfully, they will be shared into `app-sre` account via [aws-ami-share](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/aws_ami_share.py). Sharing configuration can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-ci/account.yml#L47-50)

If the new commit for infra repo does not make any change to the Packer configuration, the build job will only [update the previous Packer build AMIs tag](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/build_images.sh#L87-98). So we can still trace AMIs via infra latest commit sha. 

## Continuous Delivery

We use [terraform-resources](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#manage-aws-autoscaling-group-via-app-interface-openshiftnamespace-1yml) to create and manage auto-scaling groups. One example can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/namespaces/app-sre-ci.yaml#L96-116). 

`images` helps us to trace the latest amis and trigger Instance refresh when new amis get to build. 

`extra_tags` helps us to trace these dynamic instances for monitoring and running housekeeping jobs.

## Jenkins Plugin

Jenkins master node require IAM role to be able to manage its own node. Policy can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/app-sre-ci/ci-int-nodes.tf#L131-187)

We use groovy script to manage cloud configuration which can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ci-int-jenkins-worker.groovy). Need to use [Script Console](https://www.jenkins.io/doc/book/managing/script-console/) to update it manually. 

For EC2 Fleet cloud plugin, we can easily add an existing ASG to Jenkins with this [function](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ci-int-jenkins-worker.groovy#L228-304)

TODO: we need a new integration so we can define Jenkins cloud in app-interface and auto-update it in Jenkins instances.

## Monitoring

For the auto-scaling group, we enable [CloudWatch metrics](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/app-sre/production/ci-int-asg-1.yml#L18-39). So we can get them via AWS console [for example](https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AutoScalingGroupDetails:id=ci-int-jenkins-worker-app-interface;view=monitoring)

For running nodes, since all nodes are running node-exporter, we use [ec2_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config) to retrieve scrape targets from AWS EC2 instances. Configuration can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheus/prometheus-app-sre-additional-scrapeconfig-internal.secret.yaml#L176-190). and all targets can be found [here](https://prometheus.appsrep05ue1.devshift.net/targets#pool-jenkins_worker)


## Housekeeping

We still need to running some housekeeping jobs to help us manage these nodes. We use ansible [ec2 inventory](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ec2_inventory.html) to get inventory hosts and run jobs against it. Host configuration can be found [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/aws_ec2.yaml). Job definition can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/jenkins/app-sre/job-templates.yaml#L203-250) and jobs are [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/cicd/ci-int/jobs.yaml#L104-118)

