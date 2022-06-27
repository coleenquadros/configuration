# cloudigrade disaster recovery

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch.

See also [Data Continuity and Disaster Recovery](https://github.com/cloudigrade/cloudigrade/blob/master/docs/architecture.md#data-continuity-and-disaster-recovery) in [cloudigrade Architecture Document](https://github.com/cloudigrade/cloudigrade/blob/master/docs/architecture.md).

## Summary

Recovery steps for known sitations are described below. If a situation arises for cloudigrade that is not covered by this document and/or requires assistance from the devs, contact the cloudigrade engineering team by:

- preferred: [Ansible Slack channel `#cloudmeter-dev`](https://ansible.slack.com/archives/C8VGAPJNN) using `@here` or `@channel`
- https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml

cloudigrade and postigrade deployments are controlled by the Clowder operator. If you are not familiar with Clowder, please reference its documentation and SOPs. The cloudigrade team is not responsible for Clowder's general operation and maintenance. See also:

- https://github.com/RedHatInsights/clowder/
- https://redhatinsights.github.io/clowder/clowder/dev/sop.html
- https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/console.redhat.com/app-sops/clowder

## Recreating lost secrets

If secrets have been lost from [vault.devshift.net](https://vault.devshift.net), reach out to the engineering team to reissue them. The team will update the relevant `openshiftResources` `version`s and open an app-interface MR that will need SRE's approval to merge. Upon merge, deployments should automatically roll out with the new secrets.

- cloudigrade pods will fail to start if secrets are missing.
- cloudigrade uses `vault-secret` providers much like other services.
- See the `openshiftResources` definitions in [stage-cloudigrade-stage.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/stage-cloudigrade-stage.yml) and [cloudigrade-prod.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/cloudigrade/namespaces/cloudigrade-prod.yml).
- Secrets kept in vault that are maintained by the cloudigrade dev team include (but are not limited to) the following items:
  - AWS access keys
  - Azure IDs and client secrets
  - Django secret key
  - PSKs for other internal Red Hat services
  - Sentry DSNs
  - Slack webhook URL
- After updating or recreating secrets, versions in the aforementioned `openshiftResources` will need to be bumped, and new deployments should roll out with the new secrets.
- The cloudigrade engineering team may use [cloudigrade credentials rotation](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/cloudigrade/cloudigrade-credentials-rotation.md) as a guide if necessary, but that process is outside the scope of SRE's responsibilities here.

## Database restoration

cloudigrade and postigrade rely on the SRE-managed RDS instances. After performing the standard [AppSRE database restore procedure](https://gitlab.cee.redhat.com/service/app-interface#restoring-rds-databases-from-backups), Clowder must know the new hostname, port, etc. Clowder management and configuration is beyond the scope of this document.

- Redeploying cloudigrade and postigrade will ensure that all pods will re-read their configurations and establish new connections to the database.
  - See [cloudigrade-general-troubleshooing](cloudigrade-general-troubleshooing.md) for instructions to redeploy.
  - cloudigrade and postigrade pods read database configutaion from `$ACG_CONFIG` at startup, which is populated by Clowder.
  - cloudigrade pods always connect to postigrade for their database connections.
  - postigrade pods are running [`PgBouncer`](https://www.pgbouncer.org/) and are the only pods that should directly connect to RDS.
  - DB migrations automatically run in `cloudigrade-api`'s init container.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
