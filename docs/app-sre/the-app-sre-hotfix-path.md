# The App SRE Hotfix path

The deployment strategy for services running with the App SRE is:
1. Every commit that is merged into the main branch (`master`/`main`/...) is deployed to the stage environment.
1. Production promotions are done using a specific commit sha (a commit which was merged to the main branch).

This means that the main branch may contain changes which are not ready for production.

This SOP describes how to introduce hotfixes to production without promoting all changes from the main branch.

Note: as an example for this SOP, we will use qontract-reconcile, a service built by the App SRE team: https://github.com/app-sre/qontract-reconcile

## Actions

1. Create a branch called `hotfix` in your code repository. This branch should be created from the commit that is currently deployed to production.
    * Example:
        - Deployed commit in app-interface: https://gitlab.cee.redhat.com/service/app-interface/-/blob/6656277adbc1321b0c553253a32360a35cc730f1/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml#L53
        - Actual commit: https://github.com/app-sre/qontract-reconcile/commit/1a4ed92195f7e8fdd0f2c6a498118eb48d49e0fe
1. For operators deployed via OLM (such as [Hive](https://github.com/openshift/hive)) the `hotfix` branch should be aligned with saas bundle ordering so it can be deployed to the existing environments. This change assumes that the `hotfix` branch will never be merged into the main branch and that changes to the `hotfix` branch are always cherry-picked from main branch.
    * Example: https://github.com/openshift/hive/pull/832
1. Create a job to build an image on merges to the `hotfix` branch:
    * Example: https://gitlab.cee.redhat.com/service/app-interface/-/blob/492a7e51315f396e8fcecfc0c3a29e8b044f7281/data/services/app-interface/cicd/ci-ext/jobs.yaml#L49-51
1. Merge the hotfix changes (according to your process) to the main branch and test the changes in the stage environment.
    * Example: https://github.com/app-sre/qontract-reconcile/pull/1223
1. Cherry-pick the changes from the main branch to the `hotfix` branch (this is to avoid regressions when returning to the main branch).
    * Example: https://github.com/app-sre/qontract-reconcile/pull/1224
1. Add any required changes to keep version ordering in sync with the main branch. This is only relevant for operators.
    * Example: https://github.com/openshift/hive/pull/832
1. Once the changes are merged to the `hotfix` branch, submit a MR to app-interface to promote the changes to production using a commit sha from the `hotfix` branch.
    * Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/12773
