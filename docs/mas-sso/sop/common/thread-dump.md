- [Thread Dump for MAS SSO](#thread-dump-for-mas-sso)
   - [Prerequisites](#prerequisites)
   - [Running the Script](#running-the-script)
   - [Gather Logs](#gather-logs)


# Thread Dump for MAS SSO
 When a critical alert is firing, a thread dump should be part of the information gathered. Below are the details to get this thread dump from MAS SSO.

## Prerequisites
The mas-sso application information can be found at [mas-sso](https://visual-app-interface.devshift.net/services#/services/mas-sso/app.yml).


The namespace will be `mas-sso-stage` for staging environment and `mas-sso-production` for the production environment. Use the appropriate namespace in the commands.

CLI required to complete this SOP:
- oc
- Appropiate permissions on the OSD cluster
- [thead-dump-capture.sh](https://gitlab.cee.redhat.com/service/saas-mas-sso/-/blob/master/scripts/thread-dump-capture.sh)

## Running the Script

- Login to OSD cluster.
- Run the following command against your target cluster to get a thread dump from each container running SSO within the keycloak pods. 
  
```
Ex:   ./thread-dump-capture.sh -n <NAMESPACE> -d <OUTPUT_DIR>

      ./thread-dump-capture.sh -n mas-sso-stage -d /home/Documents/Threaddump-folder/

   OPTIONS:
   -h, --help      Help instructions
   -n, --param     Namespace
   -d, --param     Output_Dir

```

`<NAMESPACE>` parameter is required, must enter an appropiate namespace `mas-sso-stage` or `mas-sso-production`

`<OUTPUT_DIR>` parameter is optional, If no path is supplied, thread-dump-*.txt are created in the output directory.

### Gather logs

After successful execution of the script, a file for each keycloak process Id thread dump is created. Finally, upload this info to accessible place such as a Jira.
