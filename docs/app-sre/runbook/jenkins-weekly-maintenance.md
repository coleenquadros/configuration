# Jenkins


[TOC]

## Overview

This SOP captures MANUAL steps for weekly maintenance of AppSRE CI infrastructure.

This is done by utilising ansible for running command on many hosts, but you can ssh to each individual hosts and run commands if you prefer.

Examples for ci-int, but same steps ca be used for ci-ext by changing hosts.


## Architecture


![AppSRE Jenkins](img/jenkins.png "App SRE Jenkins Architecture")

## Needed credentials:

1. [Admin credentials](https://gitlab.cee.redhat.com/service/app-interface/-/blob/5a22e57f229648403c4e7882233f559066a9f0bb/data/teams/app-sre/roles/app-sre.yml#L14-15) for accessing jenkins UI
1. ssh access to controller: [direct](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all#L5) or [app-sre-bot](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ansible/roles/app-sre-bot) key for running ansible commands


## Steps:

1. Build new version of the worker AMIs. In order to do it, go to [`infra`](https://gitlab.cee.redhat.com/app-sre/infra) and force a new ami build:
    ```
    date -u > packer/FORCE_AMI_BUILD
    ```
1. Make CI instance offline 
  - go https://ci.int.devshift.net/prepareShutdown/ 
  - Type reason like "Weekly maintenance" and hit the button
  - announce in #sd-app-sre Slack channel
1. Wait for all current jobs finished or abort some long-running ones
1. Stop jenkins controller service
  - ssh to host `ssh ci.int.devshift.net`
  - `# systemctl stop jenkins`
  - NOTE: you need to stop service before rebooting controller VM. This is critical step. In case of rebooting without *prior* stopping of jenkins service reboot command may kill _ssh_ daemon and wait jenkins controller for graceful stop upto 35 minutes. That may lock instance for that period of time.
1. Clean /tmp folder on workers nodes: `ansible -u app-sre-bot --key-file app-sre-bot.key --forks=1 -m shell -a 'rm -rf /tmp/*' -b ci-int-aws-jenkins-worker`
1. Schedule reboot of controller: `# shutdown -r 1`
1. Update the reference of the AMIs in the [ASGs configuration](/data/services/app-sre/namespaces/app-sre-ci.yaml).
1. Announce end of maintenance in #sd-app-sre Slack channel

## Final check:
Go to controller console and check all workers node for status and free disk space, sometime you may need to clean some, usually by removing old container images

## Further reading

See [this doc](/docs/app-sre/jenkins-worker-cicd.md) to have more information on how to handle Jenkins dynamic nodes.
