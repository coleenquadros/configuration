# Adding quota for OSD clusters

Information needed to increase quota:

- Cluster instance type
- SKU the correlates to the cluster instance type

## Finding the Instance Type

Using visual-app-interface, bring up the console of the cluster that is to be expanded.

-  Click on the "Clusters" tab on the left hand side, then find the name of the cluster in the list.  Click on the link to the console to get access to that cluster's console.

Log into the cluster console by clicking on the `github-app-sre` IDP link.  The instance type can now be found from the console or from the command line.

### Finding the Instance Type via the Console

Once logged into the cluster click on the `Compute` grouping on the left hand side of the screen.  Once that is expanded, click on the `Nodes` link.  Select a node whose Role is `worker` and on the following screen scroll down to the `Node Labels` section.  Look for the label `beta.kubernetes.io/instance-type`.  The value of this label is the node instance type in the cluster.

### Finding the Instance Type via Commandline

Once logged into the cluster click on your user name in the upper right hand corner, and select `Copy Login Command` from the drop down.  If needed, re-authenticate to the cluster usingthe `github-app-sre` IDP link, then on the following page click the `Display Token` link.  Copy the whole command highlighted in the `Log in with this token` section and paste it into a terminal window.  Once logged into the cluster on the command line, list the nodes:

- oc get nodes

Choose any node whose role is `worker` and describe the node:

- oc describe node <node name>

Look for the `Labels` area of the output and look for the `beta.kubernetes.io/instance-type` label.  The value of this label is the node instance type in the cluster.

## Finding the SKU

The SKU determines the number of nodes of a specific instance type that can be run.  There are a few ways to determine the SKU that corresponds to the instance type on the cluster.

### Look at UHC Source

Look in this [file](https://gitlab.cee.redhat.com/service/uhc-account-manager/blob/develop/pkg/api/skus/skus_generated.go) for the list of SKUs.  Look at the ResourceName and it should match the instance type.

### Using ocm Commandline Tool

Use the ocm commandline tool as instructed [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/ocm-manage-clusters.md#ocm-cli)

NOTE: An easy way to find relevant information is to do:

- ocm get /api/accounts_mgmt/v1/skus | jq -r '.items[] | "\(.resource_type)\t\(.resource_name)\tAZ:\(.availability_zone_type)\tbyoc:\(.byoc)\t\(.id)"' | grep <instance type> | grep cluster.aws

This will likely list multiple entries.  Look for the entry that matches AZ type (single or multi) and has `byoc:false`.

The AZ type can be found in OCM.  Click on the cluster name and scroll down to `Availability`.

## Request the Quota Increase

Follow the process [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/ocm-manage-clusters.md#quotas) to determine which file to update.  Edit that file and find the SKU that matches the SKU for the instance type that is to be increased.  When increasing quota it is best to ask for a large increase.

If an entry doesn't exist for the SKU to be modified, add it to the list of SKUs with a comment describing the instance type.  Look at existing entries for examples.

