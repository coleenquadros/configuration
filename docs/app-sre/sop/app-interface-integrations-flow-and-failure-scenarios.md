# App-interface integrations flow and failure scenarios

## Background

Each MR in app-interface is running a set of integrations to compare and validate a desired state before it is merged in to app-interface and reconciled.

The list of integrations being run can be found in [manual_reconcile.sh](/hack/manual_reconcile.sh)

## Flow description

There are 3 stages when running our integrations:
1. Compliance phase: Verify that the MR can be rebased by the App SRE team.
    * Run the `gitlab-fork-compliance` integration
        * Verifies that the App SRE gitlab bot is a Maintainer on the fork
        * Adds the App SRE team members as Maintainers on the fork (acting as the bot)
        * Verifies that the MR is not using `master` as the source branch (disables rebasing)
1. Baseline collection phase: Run a small set of integrations against the production GraphQL endpoint.
    * `saas-file-owners` in no-compare mode
        * Collect information about saas file owners to prevent privilege escalation.
    * `jenkins-job-builder` in no-compare mode
        * Collect JJB data to compare with the desired state in the MR
        * pending https://issues.redhat.com/browse/APPSRE-1854
1. Integration execution phase: Run all integrations against the local GraphQL endpoint.
    * The integrations from the baseline collection phase will run again in a compare mode
        * These integrations will fail in the baseline collection phase was not completed succesfully

## Failure scenarions

This section describes common failure scenrios for different integrations.

### saas-file-owners

Mostly fails if baseline collection phase was not succesfull.
This is usually due to a data reload in the Graphql production endpoint.

Solution: `/retest`

### jenkins-job-builder

Mostly fails if baseline collection phase was not succesfull.
This is usually due to a data reload in the Graphql production endpoint.

Solution: `/retest`
