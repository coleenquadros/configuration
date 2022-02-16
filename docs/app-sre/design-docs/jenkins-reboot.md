# Design doc: making upgrades on Jenkins instances non-interactive

## Author/date

Luis Fernando Muñoz Mejías / 2022-02-01

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4254
https://issues.redhat.com/browse/APPSRE-4255
https://issues.redhat.com/browse/APPSRE-4256
https://issues.redhat.com/browse/APPSRE-4257

## Problem statement

We need to easily upgrade RPMs in our Jenkins nodes and
controllers. However, some of these interventions require rebooting
the node to take full effect (think kernel or libc upgrades).

But we cannot do it blindly. Restarting a Jenkins instance will kill
any running jobs, decreasing user satisfaction. Additionally, there is
a small chance that Jenkins won't come back after such a reboot, so we
need alerting, and ideally, not waking anyone up.

## Goals

Choose a strategy that will help us reboot Jenkins after an upgrade
without losing jobs and without requiring much human attention, other
than maybe running an Ansible playbook.

We accept that jobs will be delayded while the system drains and nodes
reboot.

## Non-goals

* Minimize downtime of each individual reboot process.
* A worfklow for sharding reboots
* Define which RPMs we must upgrade and which ones we can leave behind

## Assumptions

We assume rebooting nodes is safe. After all, they don't have any
daemons that might fail to come back.

We also assume rebooting the controller is unsafe.

If you disagree with these assumptions don't bother reading the rest
of this document.

## Proposal

Given how Jenkins works, the simplest approach is to reboot **all**
nodes and controllers if **any of them** needs a reboot. This means
doing a call to the `/safeExit` endpoint of the REST API and waiting
for ongoing jobs to finish. After that we can reboot the world.

The easiest way to achieve this is letting the controller handle the
reboot of all nodes.  We will rely on the controller's systemd to do
all the coordination work for us without blocking Ansible.

We will have a service doing the reboots, called
`reboot-jenkins-nodes.service`, and it will be called after Jenkins
finishes via `OnSuccess=`. However, to prevent any Jenkins restart or
manual intervention from rebooting all nodes, we will let this service
run only if a certain file has been populated. This way, ansible can
touch or throw contents to said file and then let Jenkins do all its
work.

``` ini
# Warning! Pseudo-unit!
[Unit]
Description=Reboot workers
After=jenkins.service
Before=reboot.target
ConditionPathExists=/run/something/ansible/can/write/to

[Service]
EnvironmentFile=FILE_WITH_ALL_WORKERS
Type=oneshot
ExecStart=sh -c "for w in $WORKERS; do ssh -l rebooter $w systemctl -f reboot; done"
```

In addition to this, we will deliver a Jenkins systemd service
(**TODO** offer said unit upstream) that will do the `/safeExit` with
the credentials of `app-sre-bot` and wait for 20 minutes before killing all
jobs.  This will prevent deadlocked jobs from stalling the reboot.

Its key features would be:

``` ini
[Unit]
Description=jenkins
OnSuccess=reboot-jenkins-nodes.service

[Service]
EnvironmentFile=FILE_WITH_CREDS
EnvironmentFile=FILE_WITH_TIMEOUTS
ExecStart=...
ExecStop=# Do safeExit here
TimeoutStopSec=$TIMEOUT_STOP
User=jenkins
Group=jenkins


[Install]
WantedBy=default.target
```

(please note that we currently start Jenkins via an init.d script that
doesn't allow for any safeExit or any configurable timeout)

We will provide with a different version of the
[node-upgrade-restart](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-upgrade-restart.yml)
playbook that will enter this target after upgrading any relevant
RPMs. To avoid coordinating what needs rebooting and what not, it
will assume that a reboot is always needed. This will be true if we
delay its execution long enough. For instance, if we upgrade every 2
to 4 weeks, we will have a very good security position while being
very unlikely that none of openssl, openssh, kernel, java or glibc
have received any updates.

### Security considerations

We will introduce a `rebooter` user that will be allowed to reboot the
node. This should prevent any user jobs from triggering reboots or
shutdowns.

### When to run this

We will produce a SOP detailing when and how to trigger this process.

## Alternatives considered

### Making nodes reboot themselves

We could make nodes reboot themselves. However this needs some logic
in detaching them, and in making them aware of whether there is any
job about to start. Race conditions are bound to hurt our
users. Handling the reboot after a `safeExit` is the best guarantee
for user jobs.

### Do it all in Ansible

This means locking the executor for a while, which is annoying. Also,
it needs more code than deploying a couple of systemd units. Testing
it would be also much harder.
