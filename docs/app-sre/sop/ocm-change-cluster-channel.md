# Change cluster channel in OCM

This SOP explains how to change a cluster's channel in OCM.

## Notes

1. Please perform this SOP only with a matching Jira ticket on the APPSRE board.
1. Get explicit +1 on the ticket from @jeder and/or @nmalik and/or @mafriedm.
1. Example ticket: https://issues.redhat.com/browse/APPSRE-2766.
1. This SOP becomes un-needed once https://issues.redhat.com/browse/SDA-3297 is implemented.

## Required information

1. Cluster ID
1. Current cluster channel (`stable`/`fast`/`candidate`/`nightly`)
1. Desired cluster channel (`stable`/`fast`/`candidate`/`nightly`)
1. OCM environment (this SOP uses `production` as an example)

## Process

1. Log into the cluster where OCM is running (currently: app-sre-prod-04)
1. rsh into the `diag-container` pod in the `app-sre` namespace. if one doesn't exist, perform the [diag-container SOP](/docs/app-sre/sop/diag-container.md):
    ```shell
    $ oc rsh $(oc get pods -l deployment=diag-container -o name)
    ```
1. Use `psql` to connect to the clusters-service DB with details from [this secret in Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/integrations-output/terraform-resources/app-sre-prod-04/uhc-production/clusters-service-rds):
    ```shell
    $ psql -h <db.host> -d <db.name> -U <db.user>
    Password for user <db.user>: <db.password>
    psql ...
    SSL connection ...
    Type "help" for help.

    postgres=>
    ```
1. Get the current cluster channel:
    ```shell
    postgres=> SELECT channel_group FROM clusters WHERE id='<cluster_id>';
     channel_group 
    ---------------
     <current_cluster_channel>
    (1 row)
    ```
1. Update the cluster to the desired channel:
    ```shell
    postgres=> UPDATE clusters SET channel_group='<desired_cluster_channel>' WHERE id='<cluster_id>';
    UPDATE 1
    ```
1. Verify the change worked as intended:
    ```shell
    postgres=> SELECT channel_group FROM clusters WHERE id='<cluster_id>';
     channel_group 
    ---------------
     <desired_cluster_channel>
    (1 row)
    ```
