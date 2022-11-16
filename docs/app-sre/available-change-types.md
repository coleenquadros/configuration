# app-interface granular permission model change-types

With the granular permission model, engineering teams & partner SRE teams can acquire more permissions to manage and support their own services in app-interface without AppSREs explicit reviews and approvals.

## How does it work?

Declarative policies (a.k.a. app-interface change-types) enables change permissions from something wide like "change everything for all namespaces in a cluster" to something fine grained as "bump the version of a single vault secret" or "change the TTL of a record in a specific DNS zone".

Declaring such change-types is a matter of defining what is desired, what makes sense and what is safe.

If a change-type is in effect for a service, team members can approve changes to their app-interface configuration on their own.

## What is available right now?

Here is a list of supported `change-types` and the `app-interfaces` [schemas](https://github.com/app-sre/qontract-schemas) they can be applied to.

| **change-type** | **description** | **applicable to** |
|-----------------|-----------------|-------------------|
| [/app-interface/changetype/gabi-signoff-manager.yml](/data/app-interface/changetype/gabi-signoff-manager.yml) | Allow a manager to approve requests related to a gabi instance.<br/> | datafile [/app-sre/gabi-instance-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/gabi-instance-1.yml) |
| [/app-interface/changetype/namespace-networkpolicies.yml](/data/app-interface/changetype/namespace-networkpolicies.yml) | Allow updates on networkpolicies of a namespace.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/changetype/saas-file-target-self-service.yml](/data/app-interface/changetype/saas-file-target-self-service.yml) | Allow updates to saas file targets.<br/> | datafile [/app-sre/saas-file-target-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/saas-file-target-1.yml) |
| [/app-interface/changetype/asg-promoter.yml](/data/app-interface/changetype/asg-promoter.yml) | Allow updating the image of an AutoScalingGroup (asg) provider in a namespace external resources<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/changetype/tekton-provider-defaults-owner.yml](/data/app-interface/changetype/tekton-provider-defaults-owner.yml) | Allows updates on tekton-provider-defaults.<br/> | datafile [/app-sre/tekton-provider-defaults-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/tekton-provider-defaults-1.yml) |
| [/app-interface/changetype/saas-file-self-service.yml](/data/app-interface/changetype/saas-file-self-service.yml) | Allow updates to saas files.<br/> | datafile [/app-sre/saas-file-2.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/saas-file-2.yml) |
| [/app-interface/changetype/namespace-owner.yml](/data/app-interface/changetype/namespace-owner.yml) | Higher level change permission on namespaces.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/changetype/add-role-member.yml](/data/app-interface/changetype/add-role-member.yml) | Owners of roles can add new role members.<br/> | datafile [/access/roles-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//access/roles-1.yml) |
| [/app-interface/changetype/scorecard-owner.yml](/data/app-interface/changetype/scorecard-owner.yml) | Allow updates on a service scorecards.<br/> | datafile [/app-sre/scorecard-2.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/scorecard-2.yml) |
| [/app-interface/changetype/shared-resources-secret-promoter.yml](/data/app-interface/changetype/shared-resources-secret-promoter.yml) | Allow bumping the version of a vault-secret in a shared resources file.<br/> | datafile [/openshift/shared-resources-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/shared-resources-1.yml) |
| [/app-interface/changetype/dns-zone-self-service.yml](/data/app-interface/changetype/dns-zone-self-service.yml) | Allow updates on DNS zone records.<br/> | datafile [/dependencies/dns-zone-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//dependencies/dns-zone-1.yml) |
| [/app-interface/changetype/cluster-owner.yml](/data/app-interface/changetype/cluster-owner.yml) | Allow all actions in namespaces of a cluster.<br/> | datafile [/openshift/cluster-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/cluster-1.yml) |
| [/app-interface/changetype/ocm-github-resource-template-editor.yml](/data/app-interface/changetype/ocm-github-resource-template-editor.yml) | Allow updates on the OCM STS policies resource template (github templating).<br/> | datafile [/openshift/shared-resources-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/shared-resources-1.yml) |
| [/app-interface/changetype/resource-owner.yml](/data/app-interface/changetype/resource-owner.yml) | Allows general updates on app-interface resources.<br/> | resourcefile [](https://github.com/app-sre/qontract-schemas/tree/main/schemas/) |
| [/app-interface/changetype/sql-query-approver.yml](/data/app-interface/changetype/sql-query-approver.yml) | Allow approving sql-query requests referencing a namespace.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/changetype/rds-maintainer.yml](/data/app-interface/changetype/rds-maintainer.yml) | Allow updates on AWS RDS instances in namespaces.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/changetype/aws-privatelink-region-enabler.yml](/data/app-interface/changetype/aws-privatelink-region-enabler.yml) | allows enabling regions for privatelink aws accounts<br/> | datafile [/aws/account-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//aws/account-1.yml) |
| [/app-interface/changetype/secret-promoter.yml](/data/app-interface/changetype/secret-promoter.yml) | Allow bumping the version of a vault-secret.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/changetype/cluster-auto-updater.yml](/data/app-interface/changetype/cluster-auto-updater.yml) | Allow updates on a cluster.<br/> | datafile [/openshift/cluster-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/cluster-1.yml) |
| [/app-interface/changetype/ocm-org-owner.yml](/data/app-interface/changetype/ocm-org-owner.yml) | Allows updates on an OCM organization file, including cluster upgrade policies.<br/> | datafile [/openshift/openshift-cluster-manager-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/openshift-cluster-manager-1.yml) |


You an idea for a new `change-type`? Let us know and create a ticket on the [AppSRE Jira Board](https://issues.redhat.com/projects/APPSRE)

## How can i use a change-type?

Have a look at the change-type documentation section [Role based self-service](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/change-types.md#role-based-self-service) to learn how to apply `change-types` within roles.
