# Onboarding a New OSD Operator

## Overview
Understanding `app-interface` -- what it does, how it is organized, and especially how to add a
hosted service -- requires a nontrivial investment of time and brain power. For drive-by users
who merely wish to add a hosted service, that investment can be wasted as they only need to
interact with `app-interface` rarely (maybe just the once).

The [`new_operator.py`](new_operator.py) utility smooths the process by encapsulating the business
logic needed to onboard a new OSD operator. It reduces what you need to know to... the name of the
operator. Its job is to generate the deltas and new files in all the right places, ready for you
to commit and push a new `app-interface` merge request.

## Prerequisites
- Python. This utility was written and tested with python 3.6.8. (It may work with python 2, but
you [should't be using that anyway](https://www.python.org/doc/sunset-python-2/).)
- The `ruamel.yaml` library from [pypi](https://pypi.org/project/ruamel.yaml/). This utility was
written and tested with version `0.16.10`.

```shell
$ python3 -m pip install --user ruamel.yaml
```

## Usage
The [`new_operator.py`](new_operator.py) utility is intended to be run on the command line from
within your local clone of the `app-interface` repository. It is assumed you know how to fork,
clone, muck with remotes, commit, push, and create merge requests.

### Run the utility
The utility takes one argument: the name of your operator. In this example, we'll assume that's
`my-wizbang-operator`. The utility assumes the code is hosted in github under the `openshift`
organization -- so in this case, `github.com/openshift/my-wizbang-operator`.

```shell
[.../app-interface]$ hack/new_osd_operator/new_operator.py my-wizbang-operator
Writing data/services/osd-operators/cicd/ci-int/jobs-my-wizbang-operator.yaml
Writing data/services/osd-operators/cicd/saas/saas-my-wizbang-operator.yaml
Writing data/services/osd-operators/namespaces/my-wizbang-operator-stage.yml
Writing data/services/osd-operators/namespaces/my-wizbang-operator-integration.yml
Writing data/services/osd-operators/namespaces/my-wizbang-operator-production.yml
Writing data/teams/sd-sre/permissions/my-wizbang-operator-coreos-slack.yml
Adding quayRepos entry for my-wizbang-operator
Adding codeComponents entry for my-wizbang-operator
Adding gitlab project saas-my-wizbang-operator-bundle to projectRequests.
Adding pr-check entry for my-wizbang-operator
Adding SAAS file entry for my-wizbang-operator
Adding slack permissions entry for my-wizbang-operator
Adding slack user group for my-wizbang-operator
[.../app-interface]$
```

### Commit the changes
The changes include both new files and deltas to existing files. Be sure to grab both.

```shell
[.../app-interface]$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   data/dependencies/gitlab/gitlab.yml
	modified:   data/dependencies/slack/coreos.yml
	modified:   data/services/osd-operators/app.yml
	modified:   data/services/osd-operators/cicd/ci-ext/jobs.yaml
	modified:   data/teams/sd-sre/roles/saas-approver.yml
	modified:   data/teams/sd-sre/roles/sre-operator-all-coreos-slack.yml

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	data/services/osd-operators/cicd/ci-int/jobs-my-wizbang-operator.yaml
	data/services/osd-operators/cicd/saas/saas-my-wizbang-operator.yaml
	data/services/osd-operators/namespaces/my-wizbang-operator-integration.yml
	data/services/osd-operators/namespaces/my-wizbang-operator-production.yml
	data/services/osd-operators/namespaces/my-wizbang-operator-stage.yml
	data/teams/sd-sre/permissions/my-wizbang-operator-coreos-slack.yml

no changes added to commit (use "git add" and/or "git commit -a")
[.../app-interface]$ git checkout -b onboard_my-wizbang-operator
M	data/dependencies/gitlab/gitlab.yml
M	data/dependencies/slack/coreos.yml
M	data/services/osd-operators/app.yml
M	data/services/osd-operators/cicd/ci-ext/jobs.yaml
M	data/teams/sd-sre/roles/saas-approver.yml
M	data/teams/sd-sre/roles/sre-operator-all-coreos-slack.yml
Switched to a new branch 'onboard_my-wizbang-operator'
[.../app-interface]$ git add -A
[.../app-interface]$ git status
On branch onboard_my-wizbang-operator
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   data/dependencies/gitlab/gitlab.yml
	modified:   data/dependencies/slack/coreos.yml
	modified:   data/services/osd-operators/app.yml
	modified:   data/services/osd-operators/cicd/ci-ext/jobs.yaml
	new file:   data/services/osd-operators/cicd/ci-int/jobs-my-wizbang-operator.yaml
	new file:   data/services/osd-operators/cicd/saas/saas-my-wizbang-operator.yaml
	new file:   data/services/osd-operators/namespaces/my-wizbang-operator-integration.yml
	new file:   data/services/osd-operators/namespaces/my-wizbang-operator-production.yml
	new file:   data/services/osd-operators/namespaces/my-wizbang-operator-stage.yml
	new file:   data/teams/sd-sre/permissions/my-wizbang-operator-coreos-slack.yml
	modified:   data/teams/sd-sre/roles/saas-approver.yml
	modified:   data/teams/sd-sre/roles/sre-operator-all-coreos-slack.yml

[.../app-interface]$ git commit -m "Onboard my-wizbang-operator"
[onboard_my-wizbang-operator 502329328] Onboard my-wizbang-operator
 12 files changed, 178 insertions(+)
 create mode 100644 data/services/osd-operators/cicd/ci-int/jobs-my-wizbang-operator.yaml
 create mode 100644 data/services/osd-operators/cicd/saas/saas-my-wizbang-operator.yaml
 create mode 100644 data/services/osd-operators/namespaces/my-wizbang-operator-integration.yml
 create mode 100644 data/services/osd-operators/namespaces/my-wizbang-operator-production.yml
 create mode 100644 data/services/osd-operators/namespaces/my-wizbang-operator-stage.yml
 create mode 100644 data/teams/sd-sre/permissions/my-wizbang-operator-coreos-slack.yml
[.../app-interface]$
```

At this point, simply push and create your merge request as usual.

## Support
This utility is owned and maintained by [SRE-P Team Omega](https://mojo.redhat.com/docs/DOC-1205943).

**It is not owned or maintained by the App SRE team.** In particular, it is not
their responsibility to keep it up to date with changes in the layout or functionality of the
artifacts in the repository.

If you try the utility and something goes wrong, or you see a change
that needs to be made, consider [contributing](#contributing), or contact SRE-P Team Omega.

## Contributing
Edit the files in this directory, commit, and create a merge request to `app-interface`. While the
maintainers of `app-interface` will ultimately need to approve the MR, they are likely to ask for
review from [SRE-P Team Omega](#support), so you may save some time by requesting those reviews
yourself.

## Future
For now, this only works if the hosted service you're onboarding is a standard OSD operator,
publicly hosted on github under the openshift organization.
It would be nice to extend it to work for other kinds of hosted service.
