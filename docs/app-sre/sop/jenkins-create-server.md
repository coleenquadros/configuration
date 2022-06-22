# Steps to install new or reinstall ci-int jenkins master on OpenStack

## Start OpenStack VM

1. Define OpenStack instance in ansible like [MR](https://gitlab.cee.redhat.com/app-sre/infra/merge_requests/2)
2. Run ansible to launch VM `ansible-playbook -l localhost playbooks/openstack-jenkins-master.yml -CD`
3. note IP of instance and add to ansible host's defenition
4. make it accessible by ssh (~/.ssh/config)
5. Run ansible to install packages etc `ansible-playbook  playbooks/node-ci-int.yaml -CD`
6. Make DNS change - in /etc/hosts or actually change  DNS

## Initial installation and configuration

1. ssh to instance and get admin password
`cat /var/lib/jenkins/secrets/initialAdminPassword`
2. Login via web-UI to jenkins
3. Install no plugins
4. Create admin user `app-sre-bot`
5. Make API Token for `app-sre-bot`
6. Put username and token to [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/jjb-ini)

## Install plugins via reconcile

1. run qontract-reconcile integration for jenkins-plugins
`qontract-reconcile --config config.debug.toml --log-level DEBUG jenkins-plugins`
2. wait for reboot, refresh browser in a minute

## Configure GitHub Auth

1. Configure gitHub OAuth app is in app-sre organization
2. Switch to matrix-based security by

- putting this to `/var/lib/jenkins/config.xml` and starting jenkins master with new configuration 
- or defining these grants via web-UI

```
<useSecurity>true</useSecurity>
    <authorizationStrategy class="hudson.security.GlobalMatrixAuthorizationStrategy">
      <permission>hudson.model.Hudson.Administer:app-sre*vault-app-sre</permission>
      <permission>hudson.model.Hudson.Administer:app-sre-bot</permission>
      <permission>hudson.model.Hudson.Administer:skryzhny</permission>
      <permission>hudson.model.Hudson.Read:app-sre</permission>
      <permission>hudson.model.Hudson.Read:app-sre*ci-int</permission>
      <permission>hudson.model.Hudson.Read:app-sre*ci-int-ro</permission>
      <permission>hudson.model.Hudson.Read:app-sre-bot</permission>
      <permission>hudson.model.Item.Build:app-sre*ci-int</permission>
      <permission>hudson.model.Item.Cancel:app-sre*ci-int</permission>
      <permission>hudson.model.Item.Configure:app-sre-bot</permission>
      <permission>hudson.model.Item.Create:app-sre-bot</permission>
      <permission>hudson.model.Item.Delete:app-sre-bot</permission>
      <permission>hudson.model.Item.Discover:app-sre-bot</permission>
      <permission>hudson.model.Item.Move:app-sre-bot</permission>
      <permission>hudson.model.Item.Read:app-sre</permission>
      <permission>hudson.model.Item.Read:app-sre*ci-int</permission>
      <permission>hudson.model.Item.Read:app-sre*ci-int-ro</permission>
      <permission>hudson.model.Item.Read:app-sre-bot</permission>
      <permission>hudson.model.Item.Workspace:app-sre-bot</permission>
      <permission>hudson.model.Run.Delete:app-sre-bot</permission>
      <permission>hudson.model.View.Configure:app-sre-bot</permission>
      <permission>hudson.model.View.Create:app-sre-bot</permission>
      <permission>hudson.model.View.Delete:app-sre-bot</permission>
      <permission>hudson.model.View.Read:app-sre</permission>
      <permission>hudson.model.View.Read:app-sre*ci-int</permission>
      <permission>hudson.model.View.Read:app-sre*ci-int-ro</permission>
      <permission>hudson.model.View.Read:app-sre-bot</permission>
      <permission>jenkins.metrics.api.Metrics.View:app-sre-bot</permission>
    </authorizationStrategy>
```
3. remove `Administer` rights from app-sre-bot user

## Copy credentials from old server or backup

1. Copy secrets and nodes definitions from old jenkins master (or backup) `tar cvzf <filename>.tgz nodes secrets/hudson.util.Secret secrets/master.key credentials.xml`
2. Stop new jenkins server `systemctl stop jenkins`
3. Restore files on new jenkins master
4. Optionally disable nodes if old jenkins master is still running, just add this to each node's `config.xml`

```
<slave>
  <temporaryOfflineCause class="hudson.slaves.OfflineCause$UserCause">
    <timestamp>1589550938368</timestamp>
    <description>
      <holder>
        <owner>hudson.slaves.Messages</owner>
      </holder>
      <key>SlaveComputer.DisconnectedBy</key>
      <args>
        <string>skryzhny</string>
        <string> : test</string>
      </args>
    </description>
    <userId>skryzhny</userId>
  </temporaryOfflineCause>
  <name>ci-int-jenkins-slave-10-test</name>
```

5. Don't forget to chown `# chown -R jenkins:jenkins /var/lib/jenkins/`
6. Start new jenkins master `systemctl start jenkins`
7. Make number of executors=0 for master, we don't want any job to be run on master

## Configure git user and email, need for talking to Gitlab

1. Go to "Manage Jenkins" > ""Configure System" and fill "Git plugin" fields
1.1. user.name is 'App-SRE Team'
1.2. user.email is 'sd-app-sre@redhat.com'

## Configure slack plugin

1. Go to "Manage Jenkins" > ""Configure System" and fill "Slack" fields
1.1. Workspace is 'coreos'
1.2. Default channel is '#sd-app-sre-info'
1.3. Credentials is 'slack-integration-token'

## Make sure jenkins trasting GitLab's SSL

1. Disable SSL checks if jenkins can't trust GitLab's SSL certificate

## Make changes to monitoring

1. Make monitoring URLs change in prom alertmanager etc, if changing URL
2. If not changing URL - change DNS host if starting replacement instance
