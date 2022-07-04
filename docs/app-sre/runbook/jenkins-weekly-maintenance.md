# Jenkins

[TOC]

## Overview

This SOP captures MANUAL steps for weekly maintenance of AppSRE CI infrastructure.

This is done by utilising ansible for running command on many hosts, but you can ssh to each individual hosts and run commands if you prefer.

Examples for ci-int, but same steps ca be used for ci-ext by changing hosts.


## Architecture


![AppSRE Jenkins](img/jenkins.png "App SRE Jenkins Architecture")


## Steps:

1. Make CI instance offline 
  - go https://ci.int.devshift.net/prepareShutdown/ 
  - Type reason like "Weekly maintenance" and hit the button
  - announce in #sd-app-sre Slack channel
1. Update kernal on all worker nodes: `ansible -u app-sre-bot --key-file app-sre-bot.key --forks=1 -m shell -a 'yum update -y kernel' -b ci-int-aws-jenkins-worker`
1. Wait for all current jobs finished or abort some long-running ones
1. Stop jenkins controller service
  - ssh to host `ssh ci.int.devshift.net`
  - `# systemctl stop jenkins`
  - NOTE: you need to stop service before rebooting controller VM. This is critical step. In case of rebooting without *prior* stopping of jenkins service reboot command may kill _ssh_ daemon and wait jenkins controller for graceful stop upto 35 minutes. That may lock instance for that period of time.
4. Clean /tmp folder on workers nodes: `ansible -u app-sre-bot --key-file app-sre-bot.key --forks=1 -m shell -a 'rm -rf /tmp/*' -b ci-int-aws-jenkins-worker`
1. Schedule reboot all workers nodes in 1 minute: `ansible -u app-sre-bot --key-file app-sre-bot.key --forks=1 -m shell -a 'shutdown -r 1' -b ci-int-aws-jenkins-worker`
1. Schedule rebot of controller: `# shutdown -r 1`
1. Announce end of maintenance in #sd-app-sre Slack channel

## Final check:
Go to controller console and check all workers node for status and free disk space, sometime you may need to clean some, usually by removing old container images

