# App-interface integrations promotions

## Background

App-interface integrations are being executed in multiple locations in multiple ways.  This SOP explains how to promote a new version of our integrations to each location.

## Process

1. If the app-interface changes you are promoting are dependent upon a schema change in [qontract-schemas](https://github.com/app-sre/qontract-schemas),
   the qontract-schemas version should be promoted first. This should be done by updating app-interface's `.env` file in its own merge request
   setting the commit sha reference from qontract-schemas repository. This can be done with `make update-schemas`
1. Ensure the change works by validating logs in `#sd-app-sre-reconcile-stage` slack channel. Note that integration runs against production data with dry-run mode so it may be possible the change is not executed.
1. Create a MR in app-interface to promote your changes from staging to
   production. `make qr-promote` automates getting the latest commit
   checksum and updating the necessary files. If there is a need to promote to
   a single environment, or for a better understanding of what `qr-promote` is
   doing, see [Updating specific environments](#updating-specific-environments).
   Make sure to not use `mawk` (Ubuntu default), as it does not support explicit number of occurrences,
   e.g., `[a-f0-9]{7}`.
1. Validate output of each integration in `app-interface JSON validation` within MR build. If there are any output logs they should be well explained by the change introduced.
1. Team members must deploy their own changes to all production environments
   the member has access to shortly after merging. As a general rule, if
   there's any reason that prevents you from deploying your changes at the
   end of your working day, you must revert your changes.
1. Every promotion MR has a link to qontract-reconcile repository that
   allows a visualization of the changes that will be deployed.
   In some cases, there might be changes queued up from multiple team
   members. **If your promotion will include changes from other team
   members, it is a courtesy to notify those team members.** Acknowledgements
   from team members will not block the promotion because merging a change
   indicates that it is production-ready.
1. Take a look to the build logs to understand what the change is doing,
   especially if there are other changes to be merged apart from yours. If
   you don't feel comfortable deploying changes of others and the person
   responsible for the change is not online, feel free to revert the change
   so that it is deployed by the change author.
1. Add a **lgtm** label to the MR via the GitLab website. The change will
   be merged as per the standard
   [continuous delivery process](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md). Newer team members should have the MR reviewed by at least one other team member for the first few times they promote qontract-reconcile (and until they are comfortable with the process).

## Updating specific environments

This section describes which files need to be updated in order to deploy to
a certain environment. This also serves as documentation for what
`make qr-promote` is automating for you.

* To promote grafana dashboards, update `ref` in [saas-qontract-dashboards](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-interface/cicd/ci-ext/saas-qontract-dashboards.yaml).
* To promote integrations running in the app-interface pr-check job running in ci-int, update `RECONCILE_IMAGE_TAG` in [.env](/.env).
* To promote integrations-manager and managed integrations running in appsrep05ue1 (internal cluster), update `ref` in [saas-qontract-manager-internal](data/services/app-interface/cicd/ci-int/saas-qontract-manager-int.yaml).
* To promote integrations running in the app-interface pr-check job running in ci-int, update `RECONCILE_IMAGE_TAG` in [.env](/.env).
* To promote openshift-saas-deploy version in all Jenkins jobs, update `qontract_reconcile_image_tag` in [global defaults](/resources/jenkins/global/defaults.yaml).
* To promote openshift-saas-deploy version in all Tekton pipelines, update `qontract_reconcile_image_tag` in [app-interface shared-resources](/data/services/app-interface/shared-resources).
    * Note: there may currently be additional shared-resources files containing `qontract_reconcile_image_tag`. It is usually needed to update all of them (search for `qontract_reconcile_image_tag`).

## Updating specific shards

> Note: there are some problems with the code that handles this approach. You should not use it until [APPSRE-6586](https://issues.redhat.com/browse/APPSRE-6586) is closed. Updates on this are coming.

If you want to promote a qontract-reconcile change for only one shard you can do this by adding a shardSpecOverride. Add it to the integration configuration in app-interface you changed. In the MR process the integration will run with the image specified in shardSpecOverride and the image configured in `.env`. The change you test must be compatible to the old image (in reference to the schema).

1. Create an override to fix the current commit i.e. `f929a38` on the shards that you don't want to update, to simplify this example we are going to use only one:
```yaml
  shardSpecOverride:
  - shardingStrategy: per-aws-account
    awsAccount:
      $ref: /aws/ter-int-dev/account.yml
    imageRef: f929a38
```
2. This needs to be added in two places in the corresponding yaml file, example MR upgrading all but `app-sre-stage` shard: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/52065:
   1. `$.pr_check.shardSpecOverride`
   1. `$.managed.[prod].shardSpecOverride`
4. Check the logs in the MR
   * It should contain reference to your changed image. i.e.:
   ```
   reconcile-terraform-resources_ter-int-dev.txt
   Unable to find image 'quay.io/app-sre/qontract-reconcile:f929a38' locally
   f929a38: Pulling from app-sre/qontract-reconcile
   ...
   Status: Downloaded newer image for quay.io/app-sre/qontract-reconcile:f929a38
   ```
   * The integration manager log should not contain logs of your change.

6. Promote `qontract-reconcile` as usual.
7. Check the promotion MR logs:
   * The integration manager log should contain the deployment for the new changes:
   ```
   [2022-09-26 11:28:50] [INFO] [openshift_base.py:apply:317] - ['apply', 'appsrep05ue1', 'app-interface-production', 'Deployment', 'qontract-reconcile-terraform-resources-ter-int-dev']
   ```
5. After merging the MR check the deployments on the Cluster. The fixed shards should run a the fixed image:
   ```
   oc get pod  -o 'custom-columns=NAME:.metadata.name,CONTAINER:.spec.containers[0].name,IMAGE:.spec.containers[0].image' | grep terraform-resources
   ...
   qontract-reconcile-terraform-resources-app-sre-758584757c-fshtw   int                        quay.io/app-sre/qontract-reconcile:ed21267
   qontract-reconcile-terraform-resources-app-sre-ci-698889d692fxh   int                        quay.io/app-sre/qontract-reconcile:ed21267
   qontract-reconcile-terraform-resources-ter-int-dev-c8fccdvg2x5   int                        quay.io/app-sre/qontract-reconcile:f929a38
   ...
   ```
