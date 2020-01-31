# Push Saas Metrics

Jenkins job: https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/push-saas-metrics/
Repo: https://github.com/app-sre/push-saas-metrics.git

## Fixing Cache corruption

Cache corruption may be the cause of failure if there is an error message similar to this one:

```
ERROR: git command error
ERROR: error running ['git', '--git-dir', '/cache/github-eclipse-che-plugin-registry', 'rev-list', '15483d1631fc3650c0675899db93a961d016ffdc..818e3331ca4456cc81934dbe0cbc1f08177a5928', '--count'] in https://github.com/eclipse/che-plugin-registry.git
```

In order to verify whether or not it's a cache corruption problem, we can try to reproduce the situation above by manually doing what the script is doing:

```
$ git clone https://github.com/eclipse/che-plugin-registry.git
$ git rev-list 15483d1631fc3650c0675899db93a961d016ffdc..818e3331ca4456cc81934dbe0cbc1f08177a5928
```

If the above command works, it is indeed a cache corruption issue.

In order to fix this, first manually disable the project in Jenkins and cancel any running jobs. Then ssh into the Jenkins slave that is running the job, and delete the specific cache folder (with sudo). For example:

```
$ ssh ci-int-jenkins-slave-05-app-sre
$ sudo rm -rf /var/lib/jenkins/workspace/push-saas-metrics/.cache/github-eclipse-che-plugin-registry/
```

Re-enable the project and run a job again.
