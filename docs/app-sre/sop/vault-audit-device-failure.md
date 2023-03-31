# Vault audit device failure

## Background
Vault writes an audit log for every action it performs. The audit device utilized by vault.devshift.net is defined within App Interface [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/prod/audit-backends/file-audit.yml)


## Impact
Per Vault documentation: 
```
If Vault cannot log into a configured audit log device, it ceases all user operations
```
If this alert is frequently firing it means requested actions are routinely being blocked.

## Access Required
Access to the `vault-prod` namespace within `appsrep05ue1` cluster.

## Troubleshooting

The likely culprit is a lack of capacity on the storage device. In our configuration of the audit device, this would mean an issue with the vault container's ephemeral local storage.  
Steps to investigate capacity issue:
1. Obtain a shell to the vault container within the current vault leader. You can retrieve the IP of the leader pod at `https://vault.devshift.net/v1/sys/leader`
2. Execute `df -h | grep /var/log/vault` to view capacity of audit device mount

If audit device mount within filesystem is at capacity, graceful deletion of the afflicted pod should be performed.

See [blocked file audit device](https://developer.hashicorp.com/vault/tutorials/monitoring/blocked-audit-devices#blocked-file-audit-device) for further details.
