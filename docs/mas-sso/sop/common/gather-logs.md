
## Gather logs
Following is a list of useful logs that might come in handy for troubleshooting purposes.
The namespace will be `mas-sso-stage` for staging environment and `mas-sso-prod` for the production environment. Use the appropriate namespace in the commands.

### RHSSO Operator logs
`
oc logs $(oc get pods -n <namespace> | grep rhsso-operator | awk '{print $1}') -n <namespace> mas-sso-rhsso-operator-logs.txt
`

### RHSSO Instance logs

Run the following command to get list of pods:
`
oc get pods -n <namespace>
`
For each POD NAME run the following command:

`
oc logs $(oc get pods -n <namespace> | grep <POD NAME> | awk '{print $1}') -n <namespace> > mas-sso-<POD NAME>-logs.txt
`
