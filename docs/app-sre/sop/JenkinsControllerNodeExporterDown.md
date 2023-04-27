# JenkinsControllerNodeExporterDown

## Severity: Critical FTS

## Impact

* Many critical alerts on Jenkins controllers depend on Node exporter to be up and running.

## Summary

Node exporter in a Jenkins controller is not running while the controller is up and running.

## Access required

* SSH access to jenkins controller node.

## Steps

* SSH into the node:
  * use `ci.int.devshift.net` for ci-int.
  * use `ci.int.ssh.devshift.net` for ci-ext.
* Check `node_exporter` service status:
  ```
  sudo systemctl status node_exporter
  ```
* If it's not running, try restarting
  ```
  sudo systemctl restart node_exporter
  ```
