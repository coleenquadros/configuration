# Using bastion host for accessing private clusters (hive)

## Getting access to bastion host bastion.ci.ext.devshift.net
1. Make MR with your public part of SSH key to [app-sre/infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/ci-ext-bastion-accounts.yml)
1. Ping app-sre in [Slack channel #sd-app-sre](https://coreos.slack.com/archives/CCRND57FW) to get MR merged.
1. Check in several minutes ater merge that You have access by `ssh bastion.ci.ext.devshift.net`

## Get IP's for private clusters You are accessing
1. Go to [visual app-interface](https://visual-app-interface.devshift.net/clusters)
1. Select clusters you need by clicking on 'Details'.
1. Click "Edit" and it will take you to the cluster details in gitlab.
1. Find <network.vpc> CIDR (network address)

## Use 'sshuttle' for tunelling to private cluster from your PC
1. Make sure you have package 'sshuttle' installed.
1. `sshuttle -r bastion.ci.ext.devshift.net <network.vpc>`
* Note: You can specify several ranges like: `sshuttle -r bastion.ci.ext.devshift.net <network.vpc>  <network.vpc> ...  <network.vpc>`
