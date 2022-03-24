# Upgrading the OS in Jenkins

To upgrade RPMs in ci int, ci ext and their nodes, use the
[`node-upgrade`](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-upgrade.yml)
playbook, like

``` shellsession
$ ansible-playbook playbooks/node-upgrade-restart.yml -e upgradehost=<name_of_host>
```

It is mostly safe to do this for controllers and nodes at the same
time. Once the controller and the nodes for an instance have finished
their upgrade, use the
[`node-rebot`](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-reboot.yml)
playbook **on the controller only** to safely reboot the entire fleet
while respecting the most user jobs.

``` shellsession
$ ansible-playbook playbooks/node-upgrade-restart.yml -e upgradehost=ci-ext-jenkins
# Or...
$ ansible-playbook playbooks/node-upgrade-restart.yml -e upgradehost=ci-int-jenkins
```
