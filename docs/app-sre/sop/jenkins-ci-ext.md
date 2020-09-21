# SOP: Jenkins CI-EXT

- [SOP: Jenkins CI-EXT](#sop-jenkins-ci-ext)
  - [JenkinsDown](#jenkinsdown)

The Jenkins servers for ci-ext are VMs running in [AWS](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:search=ci.ext;sort=desc:instanceId).

The configuration is documented in the [infa](https://gitlab.cee.redhat.com/app-sre/infra) repo [here](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/host_vars/ci.ext.devshift.net).

## JenkinsDown

The jenkins master server isn't responding.  Try to ssh into the instance:

```shell
ssh ci.ext.devshift.net
```

If name resolution fails, try findind the IP address for the `app-sre ci.ext master` EC2 instance in the app-sre account on AWS.

Once ssh'd into the master instance:

- Check if jenkins is running:

  ```shell
  sudo systemctl status jenkins
  ps -ef | grep jenkins
  ```

  systemctl should report `Active: active (running)`.

  ps should return with something like:

  `jenkins  21375     1 11 19:40 ?        00:03:09 /etc/alternatives/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=8080 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20`

- If no jenkins processes are running, start them with:

  ```shell
  sudo systemctl start jenkins
  ```

- Check logs of the process:

  ```shell
  sudo journalctl -u jenkins
  ```
