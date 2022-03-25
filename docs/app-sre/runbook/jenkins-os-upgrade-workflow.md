# Keeping the OS up to date in Jenkins

[TOC]

## Introduction

Upgrading OS packages regularly is critical for security.  Said
upgrades sometimes require rebooting the system or restarting daemons,
which means accepting some downtime. However, losing user data or
workloads is not an acceptable consequence of said downtime.

Batch systems are difficult to patch precisely because of this last
requirement: a blind reboot will lose jobs and results that may have
been going on for a long time.

We describe below the strategies and modules involved in upgrading and
rebooting our instances while preserving user's workloads.

## What is updated

RPMs provided via Yum or DNF repositories. Software downloaded via
other means (tarballs, RPMs shipped with the infra repo like Qualys)
are out of our scope.

## The entry point

Managing packages is a subset of configuration management, and thus we
use our configuration management (Ansible) system to control it. In
particular, the
[`node-upgrade`](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-upgrade.yml)
playbook upgrades all packages in a given node, but won't trigger any
reboots.

## Orchestration

Nodes can be upgraded at any time, but there may be services that need
restarting (say, restarting network daemons after upgrading Openssl or
restarting Jenkins itself after upgrading the JVM).

However, we may reboot the fleet only after upgrading the
controllers. To achieve this, we run the
[`node-reboot`](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-reboot.yml)
playbook on the controller. When the controller reboots, it will
contact each of its nodes and attempt to reboot it.

### Systemd

Our Jenkins service will perform a safe exit (i.e, exit Jenkins only
after all viable jobs have finished). Most jobs finish within 15
minutes, so giving 20 minutes to complete seems to be a fair
compromise. Jobs taking longer are most likely stuck in some infinite
loop and won't make progress anyways.

After those 20 minutes, or when all jobs have finished, whichever
happens first, systmed will start the [`jenkins-reboot`
target](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/roles/jenkins-master/templates/jenkins-reboot.target.j2). This
target contains [oneshot
services](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/roles/jenkins-master/templates/reboot-jenkins-node@.service.j2)
to reach each of the workers and reboot them if needed.

### When things reboot

Stopping Jenkins doesn't necessarily mean we want all nodes
restarted. Indeed, `reboot-jenkins-node` only runs if a control file
exists under `/run/upgrades/jenkins`. This allows manual
interventions, if necessary.

During normal OS upgrades, nodes reboot if and only if the controller
needs to reboot.

### How things reboot

Nodes have now an account called `rebooter` dedicated to reboots. It
is reachable via an [SSH
key](https://vault.devshift.net/app-sre/ansible/roles/rebooter) that
is deployed in the controller. Said key is limited to rebooting the
system via the `command=` directive in `authorized_keys`.

Each instance of `reboot-jenkins-node.service` pings its associated
node with this key to initiate the reboot.
