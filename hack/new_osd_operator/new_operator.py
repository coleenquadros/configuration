#!/usr/bin/env python3

import argparse
import os
import sys

import git
from ruamel.yaml import YAML
from git import Repo
from tempfile import TemporaryDirectory


yaml = YAML()
# Keep (redundant) quotes around keys and non-special values
yaml.preserve_quotes = True
# `---` at top of files (though all are single documents at the moment)
yaml.explicit_start = True

TPL_DIR = os.path.join("hack", "new_osd_operator")
SVC_DIR = os.path.join("data", "services", "osd-operators")
TEAM_DIR = os.path.join("data", "teams", "sd-sre")
CICD_DIR = os.path.join(SVC_DIR, "cicd")
OLM_TPL_FILE = os.path.join("hack", "olm-registry", "olm-artifacts-template.yaml")
GH_OPENSHIFT = "https://github.com/openshift/"


def parse_args():
    parser = argparse.ArgumentParser(description="Register a new OSD operator.")
    parser.add_argument("operator_name", help="The name of the operator to register.")
    parser.add_argument("-l", "--local-operator", help="path to local operator 'repo'. Useful for testing")
    return parser.parse_args()


def err(msg):
    print(msg, file=sys.stderr)
    sys.exit(-1)


def load_tpl(fpath, subs, skip_format=False):
    """Loads and interpolates a template file containing {format} placeholders,
    returning it as a string.
    """
    try:
        with open(fpath) as f:
            content = f.read()
        if subs:
            return content.format(**subs)
        # This is a little weird: it accounts for loading non-template YAMLs containing empty dicts
        return content if skip_format else content.format("{}")
    except Exception as e:
        err(
            "Failed to load and populate template "
            + fpath
            + " with subs "
            + str(subs)
            + "\n"
            + e
        )


def load_yml(fpath, subs=None, skip_format=False):
    """Loads and interpolates a template file containing {format} placeholders,
    interprets it as YAML, and returns the resulting dict.
    """
    try:
        return yaml.load(load_tpl(fpath, subs, skip_format))
    except Exception as e:
        err(
            "Failed to load and populate yaml template "
            + fpath
            + " with subs "
            + str(subs)
            + "\n"
            + e
        )


def dump_yml(fpath, yml, **yaml_attrs):
    """Writes a dict as YAML to a file. The file is created or
    replaced.

    :param fpath: String path to the file to write.
    :param yml: YAML document object.
    :param yaml_attrs: Optional attributes to set on the emitter.
            The original values are restored after dumping.
    """
    # Save the original values
    orig_attrs = {}
    for k, v in yaml_attrs.items():
        orig_attrs[k] = getattr(yaml, k)
        setattr(yaml, k, v)

    with open(fpath, "w+") as f:
        yaml.dump(yml, f)

    # Restore the original values
    for k, v in orig_attrs.items():
        setattr(yaml, k, v)


def seq_inject(seq, items):
    """Inject new items into a sequence (list)."""
    # NOTE(efried): We're prepending here because comments and extra newlines
    # stick with the *preceding* line with ruamel.yaml, so appending would put
    # the item after the comment/newline, which is ugly.
    for item in items[::-1]:
        seq.insert(0, item)


def inject_from_yml_tpl(chunkname, items, operator_name):
    """Extends `items` with the list loaded and
    interpolated from template file {chunkname}.yml.tpl.

    Idempotence is *roughly* checked by assuming no action is necessary
    if `items` contains an entry with a `name` of `operator_name`.
    """
    # Already there?
    # NOTE: this assumes if the operator entry exists, the other entry
    # does too.
    for entry in items:
        if entry["name"] == operator_name:
            print(chunkname + " entries already exist for " + operator_name)
            return

    print("Adding " + chunkname + " entry for " + operator_name)
    new_items = load_yml(
        os.path.join(TPL_DIR, chunkname + ".yml.tpl"),
        subs={"operator_name": operator_name},
    )
    seq_inject(items, new_items)


def update_app_yml(operator_name):
    """Adds quayRepos and codeComponents entries to app.yml."""
    fpath = os.path.join(SVC_DIR, "app.yml")
    app_yml = load_yml(fpath)

    inject_from_yml_tpl("quayRepos", app_yml["quayRepos"][0]["items"], operator_name)

    inject_from_yml_tpl("codeComponents", app_yml["codeComponents"], operator_name)

    dump_yml(fpath, app_yml)


def update_gitlab_yml(operator_name):
    """Idempotently registers the operator's SAAS bundle in gitlab.yml."""
    fpath = os.path.join("data", "dependencies", "gitlab", "gitlab.yml")
    yml = load_yml(fpath)

    projects = yml["projectRequests"][0]["projects"]
    bundle = "saas-%s-bundle" % operator_name

    # Already there?
    if bundle in projects:
        print("gitlab project " + bundle + " already in projectRequests.")
        return

    print("Adding gitlab project " + bundle + " to projectRequests.")
    seq_inject(projects, [bundle])

    dump_yml(fpath, yml)


def update_jobs_yaml(operator_name):
    """Idempotently adds a pr-check entry to jobs.yaml."""
    fpath = os.path.join(CICD_DIR, "ci-ext", "jobs.yaml")
    yml = load_yml(fpath)

    jobs = yml["config"][0]["project"]["jobs"]

    # Already there?
    for job in jobs:
        if job.get("gh-pr-check", {}).get("gh_repo", "") == operator_name:
            print("pr-check entry for " + operator_name + " already exists")
            return

    print("Adding pr-check entry for " + operator_name)
    new_jobs = load_yml(
        os.path.join(TPL_DIR, "pr-check-job.yml.tpl"),
        subs={"operator_name": operator_name},
    )
    seq_inject(jobs, new_jobs)

    dump_yml(fpath, yml)


def update_saas_approver_yml(operator_name):
    """Idempotently registers the operator's SAAS file in saas-approver.yml."""
    fpath = os.path.join(TEAM_DIR, "roles", "saas-approver.yml")
    yml = load_yml(fpath)

    saas_files = yml["owned_saas_files"]

    # Already there?
    for saas_file in saas_files:
        if saas_file.get("$ref", "").endswith("/saas-" + operator_name + ".yaml"):
            print("SAAS file entry for " + operator_name + " already exists.")
            return

    print("Adding SAAS file entry for " + operator_name)
    refs = load_yml(
        os.path.join(TPL_DIR, "owned-saas-file.yml.tpl"),
        subs={"operator_name": operator_name},
    )
    seq_inject(saas_files, refs)

    dump_yml(fpath, yml)


def update_slack_roles_yml(operator_name):
    """Idempotently registers the operator's slack permissions file in
    sre-operator-all-coreos-slack.yml.
    """
    fpath = os.path.join(TEAM_DIR, "roles", "sre-operator-all-coreos-slack.yml")
    yml = load_yml(fpath)

    perms = yml["permissions"]

    # Already there?
    for perm in perms:
        if perm.get("$ref", "").endswith("/" + operator_name + "-coreos-slack.yml"):
            print("Slack permissions entry for " + operator_name + " already exists.")
            return

    print("Adding slack permissions entry for " + operator_name)
    refs = load_yml(
        os.path.join(TPL_DIR, "slack-perm-role.yml.tpl"),
        subs={"operator_name": operator_name},
    )
    seq_inject(perms, refs)

    dump_yml(fpath, yml)


def update_slack_user_groups_yml(operator_name):
    """Idempotently registers the operator's slack user group in
    slack/coreos.yml.
    """
    fpath = os.path.join("data", "dependencies", "slack", "coreos.yml")
    yml = load_yml(fpath)

    groups = yml["managedUsergroups"]

    # Already there
    if operator_name in groups:
        print("Slack user group for " + operator_name + " already registered.")
        return

    print("Adding slack user group for " + operator_name)
    seq_inject(groups, [operator_name])

    dump_yml(fpath, yml)


def write_from_template(tplname, destfmt, operator_name, **subs):
    """(Over)writes a file from a template.

    :param tplname: Name of the template file, assumed to be in TPL_DIR.
    :param destfmt: Format string (printf-style) of the relative path to the
            destination file to be written. The `%s` will be substituted with
            the operator_name. E.g.  'path/to/foo-%s-bar.yaml'.
    :param operator_name: String name of the operator. Will be substituted into
            `detsfmt`. Will also be included in the template file's
            substitutions with key `operator_name`.
    :param subs: Additional substitutions for the template, if needed.
    """
    # NOTE: This will replace the file if it already exists. That ought
    # to be okay, if you're using git sanely.
    dest = destfmt % operator_name
    try:
        ci_int = load_tpl(
            os.path.join(TPL_DIR, tplname), dict(subs, operator_name=operator_name)
        )
        with open(dest, "w+") as f:
            print("Writing " + dest)
            f.write(ci_int)
    except Exception as e:
        err("Failed to write " + dest + ": " + e)


def prerequisites(operator_name, local_folder=None):
    """
    Prerequisites retrieves a few information on the operator's git repo:
        - It makes sure the repository is public by cloning https://github.com/openshift/{operator_name}
        - It checks if the operator was created with boilerplate
        - It retrieves the latest commit
        - It reads the olm-artifacts-template config to retrieve the managedResourceTypes
    :param operator_name: String name of the operator
    :param local_folder: Path to local folder for test operator. Used only for testing
    """
    config = {}
    with TemporaryDirectory() as tmp_clone_folder:
        if local_folder:
            operator_folder = local_folder
            prod_commit = ""  # when testing in local, the latest is irrelevant, and might not be available
        else:
            operator_folder = tmp_clone_folder
            try:
                # Clone the operator repo to a temporary directory
                repo_url = "{}/{}.git".format(GH_OPENSHIFT, operator_name)
                repo = Repo.clone_from(repo_url, operator_folder)
                prod_commit = repo.head.commit  # latest commit to be added to saas-{operator_name}.yaml
            except Exception as e:
                err("Cloning {} failed. Is it public?: ".format(repo_url))

        # Check if operator was created with boilerplate
        config['uses_boilerplate'] = True if os.path.isdir(os.path.join(operator_folder, 'boilerplate')) else False

        # ask the user wants to use a different commit than the latest one for production
        config['prod_commit'] = input("Please provide commit to deploy to Hive Production. default [{}]"
                                      .format(prod_commit)) or prod_commit

        # retrieve managedResourceTypes from the hack/olm-registry/olm-artifacts-template.yaml
        olm_tpl_path = os.path.join(operator_folder, OLM_TPL_FILE)
        if not os.path.isfile(olm_tpl_path):
            err("file {} is required for this automation to work".format(OLM_TPL_FILE))

        # using a set guarantees that resources are only declared onces
        config['resource_types'] = {item['kind'] for item in load_yml(olm_tpl_path, skip_format=True)['objects']}

    return config


def main():
    args = parse_args()

    # check prerequisites
    config = prerequisites(args.operator_name, local_folder=args.local_operator)

    # This will be used to automatically `git add` every file that needs to be committed in the first MR.
    # The remaining files (for the 2nd MR) won't be added. The user can commit them separately
    current_repo = git.Repo(os.getcwd())

    # Add ci-int/jobs file
    write_from_template(
        "ci-int-jobs.tpl",
        os.path.join(CICD_DIR, "ci-int", "jobs-%s.yaml"),
        args.operator_name,
        command="make build-push" if config['uses_boilerplate'] else "./hack/app_sre_build_deploy.sh"
    )
    current_repo.git.add(os.path.join(CICD_DIR, "ci-int", "jobs-{}.yaml".format(args.operator_name)))

    # Add cicd/saas file
    write_from_template(
        "cicd-saas.tpl",
        os.path.join(CICD_DIR, "saas", "saas-%s.yaml"),
        args.operator_name,
        commit=config['prod_commit'],
        managed_resource_types=list(config['resource_types'])
    )

    # Add namespace files for stage/int/prod
    if not config['uses_boilerplate']:
        for level in ("stage", "integration", "production"):
            write_from_template(
                "namespace.tpl",
                os.path.join(SVC_DIR, "namespaces", "%s-" + level + ".yml"),
                args.operator_name,
                level=level,
            )
            current_repo.git.add(os.path.join(SVC_DIR, "namespaces", "{}-{}.yml".format(args.operator_name, level)))

    # Add slack permissions
    write_from_template(
        "perms-slack.tpl",
        os.path.join(TEAM_DIR, "permissions", "%s-coreos-slack.yml"),
        args.operator_name,
    )
    current_repo.git.add(os.path.join(TEAM_DIR, "permissions", "{}-coreos-slack.yml".format(args.operator_name)))

    # Add quayRepos and codeComponents entries
    update_app_yml(args.operator_name)
    current_repo.git.add(os.path.join(SVC_DIR, "app.yml"))

    # Add gitlab bundle project request
    update_gitlab_yml(args.operator_name)
    current_repo.git.add(os.path.join("data", "dependencies", "gitlab", "gitlab.yml"))

    # Register the pr-check job
    if not config['uses_boilerplate']:
        update_jobs_yaml(args.operator_name)
        current_repo.git.add(os.path.join(CICD_DIR, "ci-ext", "jobs.yaml"))

    # Register the saas file
    update_saas_approver_yml(args.operator_name)

    # Register the slack permissions file
    update_slack_roles_yml(args.operator_name)

    # Register the slack user group
    update_slack_user_groups_yml(args.operator_name)


if __name__ == "__main__":
    main()
