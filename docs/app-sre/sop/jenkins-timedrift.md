# Resolve time drift issue on jenkins nodes. This procedure can be used for any hosts managed by ansible in AppSRE [infra](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible/playbooks) repo.

## Issue Description
Jenkins nodes using ntpd service have a time drift and looses ability to synchronize time.
This was observed on our ci-int infrastructure which points to Red Hat internal time servers.

## Identifying the issue
On the Jenkins > nodes you would notice the time difference in the "Clock Difference" column

## Possible Cause for this issue
ntpd resolves the DNS for the time server only when starting but when there is a change in IP for time server/DNS update, ntpd tries to connect to the decommissioned time server and loses the ability to synchronize time.

## Temporary resolution
    Restart the ntpd service on the node

## Permanent resolution
On all the jenkins nodes switch the time synchronization service from ntpd to chronyd.

1. In the [Infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible/playbooks), locate the playbook used to deploy the jenkins nodes. 
For example for ci-int associated playbooks are
    node-ci-int-aws-jenkins-worker.yml
    node-ci-int.yaml
2. In the playbooks replace role 
    { role: ntp, tags: ntp }
    with
    { role: chrony, tags: chrony }
3. If the hosts are in internal Red Hat nework, add/replace the following variable to the group_vars for the associated hosts group.
Replace "internal_ntp: yes" with "internal_chrony: yes"
The above adds clock.corp.redhat.com RedHat internal time server to the chrony.conf 
4. Create a MR with the above changes and run the playbook from your local machine once the MR is merged.

## Related Documentation
1. [Example MR](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/154)
2. [Setup SSH to run playbooks locally](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible#ssh-setup)
3. Add your ssh pub key to this [file](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all) to get root access to all hosts managed by AppSRE in the infra repo
4. [Jira Ticket related to this issue](https://issues.redhat.com/browse/APPSRE-2420)

