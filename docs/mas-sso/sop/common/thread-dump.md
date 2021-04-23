## Thread Dump for MAS SSO
When a critical alert is firing, a thread dump should be part of the information gathered. Below are the commands to get this thread dump from MAS SSO
The namespace will be `mas-sso-stage` for staging environment and `mas-sso-production` for the production environment. Use the appropriate namespace in the commands.


### RHSSO Thread Dumps

MAS SSO is a java based product. Run the following commands to get a thread dump from each container running SSO within the keycloak pods

Get the Java Process PID from each container:

`for p in $(oc get --no-headers=true pods -o name | awk -F "/" '{print $2}' | grep keycloak); do echo $p; oc exec $p -c keycloak -it -- pgrep -f java; done;`

Next put the pids in an array in the order they were outputted

`
pids=(<PIDS in order>) # E.G pids=(799 799 800)
`
Next run the jstack command in each SSO container and send the output to a local file.

`
for i in ${!pids[@]}; do oc exec keycloak-$i -c keycloak -it -- jstack ${pids[$i]} > keycloak-$i-dump.txt; done
`

Finally upload this info to accessible place such as a Jira.`
`

