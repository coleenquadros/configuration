## Skipping Remaining Reconciliation

As of writing, a vault-manager deployment within `appsrep05ue1` handles reconciliation for vault.devshift.net, vault.stage.devshift.net, and vault.ci.ext.devshift.net. If an error is encountered during any portion of reconciliation for one of these instances, there will be output within the vault-manager container stating `SKIPPING REMAINING RECONCILIATION for <instance address>`.  

NOTE: these errors will not impede reconciliation for other Vault instances. 

Vault manager reconciles resources for each instance in the following order:
* policies
* audit backends
* secret engines
* roles
* entities
* groups

To debug, first note what portion (resource) of reconcile process the `SKIPPING REMAINING RECONCILE` output occurs within (this should be stated in error output). Next, look for recent changes within [vault config](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/vault.devshift.net/config) for the afflicted instance and the specific resource subdirectory.
