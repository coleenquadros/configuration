## App-Interface integrations dependencies

| Integrations | github | quay-membership | quay-repos | openshift-namespaces | openshift-groups | openshift-resources | openshift-rolebinding | ldap-users | terraform-resources | terraform-users | jenkins-roles | jenkins-plugins | aws-garbage-collector | aws-iam-keys |
| :-------------------- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| github                |     |     |     |     |     |     |     |  X  |     |     |     |     |     |     |
| quay-membership       |     |     |     |     |     |     |     |  X  |     |     |     |     |     |     |
| quay-repos            |     |     |     |     |     |     |     |  X  |     |     |     |     |     |     |
| openshift-namespaces  |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
| openshift-groups      |     |     |     |     |     |     |     |  X  |     |     |     |     |     |     |
| openshift-resources   |     |     |     |  X  |     |     |     |     |     |     |     |     |     |     |
| openshift-rolebinding |  X  |     |     |  X  |     |     |     |  X  |     |     |     |     |     |     |
| ldap-users            |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
| terraform-resources   |     |     |     |  X  |     |     |     |     |     |     |     |     |     |     |
| terraform-users       |     |     |     |     |     |     |     |  X  |     |     |     |     |     |     |
| jenkins-roles         |     |     |     |     |     |     |     |  X  |     |     |     |     |     |     |
| jenkins-plugins       |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
| aws-garbage-collector |     |     |     |     |     |     |     |     |  X  |  X  |     |     |     |     |
| aws-iam-keys          |     |     |     |     |     |     |     |     |     |     |     |     |     |     |

Notes:
* Columns are the dependencies, rows are the dependant.