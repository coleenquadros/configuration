# app-interface granular permission model change-types

With the granular permission model, engineering teams & partner SRE teams can acquire more capabilities to manage and support their own services in app-interface without AppSREs explicit reviews and approvals.

## How does it work?

Declarative policies (a.k.a. app-interface change-types) enables change permissions from something wide like "change everything for all namespaces in a cluster" to something fine grained as "bump the version of a single vault secret" or "change the TTL of a record in a specific DNS zone".

Declaring such policies is a matter of defining what is desired, what makes sense and what is safe.

## What is available right now?

Here is a list of supported `change-types` and the `app-interfaces` [schemas](https://github.com/app-sre/qontract-schemas) they can be applied to.

| **change-type** | **description** | **applicable to** |
|-----------------|-----------------|-------------------|
| [/app-interface/change-types/gabi-signoff-manager.yml](gabi-signoff-manager.yml) | Allow a manager to approve requests related to a gabi instance.<br/> | datafile [/app-sre/gabi-instance-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/gabi-instance-1.yml) |
| [/app-interface/change-types/namespace-networkpolicies.yml](namespace-networkpolicies.yml) | Allow updates on networkpolicies of a namespace.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/change-types/saas-file-target-self-service.yml](saas-file-target-self-service.yml) | Allow updates to saas file targets.<br/> | datafile [/app-sre/saas-file-target-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/saas-file-target-1.yml) |
| [/app-interface/change-types/asg-promoter.yml](asg-promoter.yml) | Allow updating the image of an AutoScalingGroup (asg) provider in a namespace external resources<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/change-types/tekton-provider-defaults-owner.yml](tekton-provider-defaults-owner.yml) | Allows updates on tekton-provider-defaults.<br/> | datafile [/app-sre/tekton-provider-defaults-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/tekton-provider-defaults-1.yml) |
| [/app-interface/change-types/saas-file-self-service.yml](saas-file-self-service.yml) | Allow updates to saas files.<br/> | datafile [/app-sre/saas-file-2.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/saas-file-2.yml) |
| [/app-interface/change-types/namespace-owner.yml](namespace-owner.yml) | Higher level change permission on namespaces.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/change-types/add-role-member.yml](add-role-member.yml) | Owners of roles can add new role members.<br/> | datafile [/access/roles-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//access/roles-1.yml) |
| [/app-interface/change-types/scorecard-owner.yml](scorecard-owner.yml) | Allow updates on a service scorecards.<br/> | datafile [/app-sre/scorecard-2.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//app-sre/scorecard-2.yml) |
| [/app-interface/change-types/shared-resources-secret-promoter.yml](shared-resources-secret-promoter.yml) | Allow bumping the version of a vault-secret in a shared resources file.<br/> | datafile [/openshift/shared-resources-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/shared-resources-1.yml) |
| [/app-interface/change-types/dns-zone-self-service.yml](dns-zone-self-service.yml) | Allow updates on DNS zone records.<br/> | datafile [/dependencies/dns-zone-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//dependencies/dns-zone-1.yml) |
| [/app-interface/change-types/cluster-owner.yml](cluster-owner.yml) | Allow all actions in namespaces of a cluster.<br/> | datafile [/openshift/cluster-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/cluster-1.yml) |
| [/app-interface/change-types/ocm-github-resource-template-editor.yml](ocm-github-resource-template-editor.yml) | Allow updates on the OCM STS policies resource template (github templating).<br/> | datafile [/openshift/shared-resources-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/shared-resources-1.yml) |
| [/app-interface/change-types/resource-owner.yml](resource-owner.yml) | Allows general updates on app-interface resources.<br/> | resourcefile [](https://github.com/app-sre/qontract-schemas/tree/main/schemas/) |
| [/app-interface/change-types/sql-query-approver.yml](sql-query-approver.yml) | Allow approving sql-query requests referencing a namespace.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/change-types/rds-maintainer.yml](rds-maintainer.yml) | Allow updates on AWS RDS instances in namespaces.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/change-types/aws-privatelink-region-enabler.yml](aws-privatelink-region-enabler.yml) | allows enabling regions for privatelink aws accounts<br/> | datafile [/aws/account-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//aws/account-1.yml) |
| [/app-interface/change-types/secret-promoter.yml](secret-promoter.yml) | Allow bumping the version of a vault-secret.<br/> | datafile [/openshift/namespace-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/namespace-1.yml) |
| [/app-interface/change-types/cluster-auto-updater.yml](cluster-auto-updater.yml) | Allow updates on a cluster.<br/> | datafile [/openshift/cluster-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/cluster-1.yml) |
| [/app-interface/change-types/ocm-org-owner.yml](ocm-org-owner.yml) | Allows updates on an OCM organization file, including cluster upgrade policies.<br/> | datafile [/openshift/openshift-cluster-manager-1.yml](https://github.com/app-sre/qontract-schemas/tree/main/schemas//openshift/openshift-cluster-manager-1.yml) |


You an idea for a new `change-type`? Let us know and create a ticket on the [AppSRE Jira Board](https://issues.redhat.com/projects/APPSRE)

## How can i use a change-type?

To leverage the change permissions of a `change-type` for certain app-interface files, add a `self_service` section like the following one to a role.

```yaml
$schema: /access/role-1.yml

name: my-role
...
self_service:
- change_type:
    $ref: /app-interface/changetype/rds-maintainer.yml
  datafiles:
  - $ref: /services/dashdot/namespaces/app-sre-stage-01.yml
- change_type:
    $ref: /app-interface/changetype/resource-owner.yml
  resources:
  - /jenkins/global/defaults.yaml
```

This associates the `change-type` `/app-interface/changetype/rds-maintainer.yml` with the namespace file `/services/dashdot/namespaces/app-sre-stage-01.yml` found under `datafiles` in `app-interface`.
Additonally it also relates the `change-type` `/app-interface/changetype/resource-owner.yml` with the resource file `/jenkins/global/defaults.yaml` found under `resources` in `app-interface`.

The role members will gain approval permissions for merge-requests covered by this `self_service` configuration.
