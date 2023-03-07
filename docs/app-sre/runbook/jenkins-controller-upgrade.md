# Upgrading of jenkins controller service

[TOC]

## Introduction

Jenkins controller software is divided into 2 parts - core service and plugins

1. For updating core system we're using yum command, like "yum update jenkins"
2. For updating plugins we need to use [web-interface|https://stage.int.devshift.net/pluginManager/]


## When to update

After critical security fixes made public we usually have 90 day windows for upgrading Jenkins controllers

It initiated by ProdSecposts to lists:
1. product-security-cicd-tool-data
1. prodsec-supplychain


## What is updated

All 3 enviroments need to be updated:

1. [Stage|https://stage.int.devshift.net/]
1. [CI-ext|https://ci.ext.devshift.net/]
1. [CI-int|https://ci.int.devshift.net/]


## Preparations

1. Make sure you have [ssh access|https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all#L5] to controllers' hosts
1. Announce some downtime in Slack channel
1. Make sure you have backups of configs (/var/lib/jenkins/backup)
1. If you updating plugins it's good idea to copy current plugins binaries (/var/lib/jenkins/plugins) to some safer location. You can download older versions of plugins but having them stored locally wil speed-up procss if you need to restore


## Upgrade

1. Make CI instance offline
  - go https://stage.int.devshift.net/prepareShutdown/
  - Type reason like "Update maintenance" and hit the button
1. Wait for all current jobs finished or abort some long-running ones
1. ssh to host `ssh stage.int.devshift.net`
1. Stop Jenkins controller servce `# systemctl stop jenkins`
1. `# yum update jenkins` - please pay attention to exact version is picked for updgrade, sometime you need to specify exact version
1. Visit [Plugin-manager web-interface|https://stage.int.devshift.net/pluginManager/] if you need to update/install plugins
1. Start Jenkins controller servce `# systemctl start jenkins`
1. Test it...
1. Announce end of maintenance.