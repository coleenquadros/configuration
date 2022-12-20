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
written and tested with version `0.17.4`.
- The `GitPython` library from [pypi](https://pypi.org/project/GitPython/). This utility was written
and test with `3.1.14`.

```shell
$ python3 -m pip install -r requirements.txt --user
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
Writing data/teams/sd-sre/permissions/my-wizbang-operator-coreos-slack.yml
Adding quayRepos entry for my-wizbang-operator
Adding codeComponents entry for my-wizbang-operator
Adding gitlab project saas-my-wizbang-operator-bundle to projectRequests.
Adding SAAS file entry for my-wizbang-operator
Adding slack permissions entry for my-wizbang-operator
Adding slack user group for my-wizbang-operator
[.../app-interface]$
```

### Commit the changes
It is recommended to submit those files in 2 separate MRs.  
The script will automatically `git add` the files necessary for the 1st MR

```shell
[.../app-interface]$ git status
...
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   data/dependencies/gitlab/gitlab.yml
	modified:   data/services/osd-operators/app.yml
	new file:   data/services/osd-operators/cicd/ci-int/jobs-my-wizbang-operator.yaml
	new file:   data/teams/sd-sre/permissions/my-wizbang-operator-coreos-slack.yml
```

Commit those files to your branch with `git commit -m "Your commit message (1/2)"` push and create the 1st MR. 

For the 2nd MR, `git add/commit/push` the remaining files. 
```shell
...
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   data/dependencies/slack/redhat-internal.yml
	modified:   data/teams/sd-sre/roles/saas-approver.yml
	modified:   data/teams/sd-sre/roles/sre-operator-all-coreos-slack.yml

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	data/services/osd-operators/cicd/saas/saas-my-wizbang-operator.yaml	
```
The first 2 MRs will only deploy your operator to Staging and Integration. To Deploy your operator in Production run
```shell
[.../app-interface]$ hack/new_osd_operator/new_operator.py my-wizbang-operator --prod
```
## Hive vs Cluster operators 
The automation relies on the metadata of your operator's `hack/olm-registry/olm-artifacts-template.yaml` to determine
the type of operator you are trying to deploy. 
### For Cluster operators
You have no template to update.

### For Hive operators
Prior to running the automation, you will need to update the [operator.tpl](operator.tpl) with resources you need deployed in
your namespace: Secrets, ConfigMaps, ... Please refer to the app-interface README.md for information.


## Testing
To test this script locally:
- Create a temporary folder for the operator. For e.g `mkdir /tmp/my-wizbang-operator`
- Add a olm-artifact-template file to `/tmp/my-wizbang-operator/hack/olm-registry/olm-artifacts-template.yaml` (must be valid)  
- To simulate using boilerplate, create the folder `/tmp/my-wizbang-operator/boilerplate`
- Run `./hack/new_osd_operator/new_operator.py my-wizbang-operator -l /tmp/my-wizbang-operator`

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
