# Bastion access for tenants

`bastion.ci.int.devshift.net` host is used to access private clusters, clusters with API servers that are not exposed to internet. The bastion is located in a VPC peered with the private clusters managed in app-interface.

We give bastion access for tenants that work with our private clusters, such as hive/hypershift:

* If a person has a user file in app-interface, and that user file grants them access to a private cluster, the infra request is as good as approved, there's no need for further manager approval.
* If the user in app-interface does not have access to the private clusters, it means that they didn't ask for the roles in app-interface yet.

Once the infra MR is merged, there is no need to do anything manual. This [job](https://ci.int.devshift.net/job/gl-build-master-ansible-playbook-bastion-accounts/) will take care of deploying the public key in the bastion.

## Getting access to bastion host bastion.ci.int.devshift.net
1. Make MR with your public part of SSH key to [app-sre/infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/bastion-accounts.yml)
1. Ping app-sre in [Slack channel #sd-app-sre](https://redhat-internal.slack.com/archives/CCRND57FW) to get MR merged.
1. Check in several minutes after merge that You have access by `ssh bastion.ci.int.devshift.net`

## Get IP's for private clusters you are accessing
1. Go to [visual app-interface](https://visual-app-interface.devshift.net/clusters)
1. Select the cluster you want to access
1. Find `<network.vpc>` CIDR (network address)

## Use 'sshuttle' for tunelling to private cluster from your PC
1. Make sure you have package 'sshuttle' installed.
1. If you are using mac run: 
` sudo route add -net <network.vpc> -interface en0`
1. `sshuttle -r bastion.ci.int.devshift.net <network.vpc>`
* Note: You can specify several ranges like: `sshuttle -r bastion.ci.int.devshift.net <network.vpc>  <network.vpc> ...  <network.vpc>`
