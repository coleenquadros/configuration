#!/usr/bin/env python3

import argparse
import os
import sys
import shutil

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
    parser.add_argument(
        "--prod", help="add to deploy your operator in production", action="store_true"
    )
    parser.add_argument(
        "-l",
        "--local-operator",
        help="path to local operator 'repo'. Useful for testing",
    )
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


def update_slack_user_groups_yml(operator_name):
    """Idempotently registers the operator's slack user group in
    slack/redhat-internal.yml.
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


def update_cicd_saas_yml(operator_name, config):
    """
    updates the saas-operator.yaml based on object kinds from olm-artifacts-template.yaml
    """
    # First, we create the base cicd-saas yaml without the resourceTemplates
    write_from_template(
        "cicd-saas.tpl",
        os.path.join(CICD_DIR, "saas", "saas-%s.yaml"),
        operator_name,
        managed_resource_types=list(config["resource_types"]),
    )

    # Then, we update the resourceTemplates section
    fpath = os.path.join(CICD_DIR, "saas", "saas-{}.yaml".format(operator_name))
    yml = load_yml(fpath)
    resource_templates = yml["resourceTemplates"]

    # Get all current hives instances
    # Every new hive instance will have a folder in "data/services/osd-operators/namespaces"
    hive_instances = [
        entry.name
        for entry in os.scandir(os.path.join(SVC_DIR, "namespaces"))
        if entry.is_dir()
    ]

    for hive_instance in hive_instances:
        # we will only specify the commit to deploy in Production if the --prod option is provided
        # From the naming convention Production hive instance names all start with 'hivep'. for e.g hivep04ew2
        if hive_instance.startswith("hivep") and not config["prod_commit"]:
            continue

        tpl_ending = (
            "prd.yml.tpl" if hive_instance.startswith("hivep") else "staging.yml.tpl"
        )
        refs = load_yml(
            os.path.join(TPL_DIR, "cicd-saas-namespace-{}".format(tpl_ending)),
            subs={
                "operator_name": operator_name,
                "hive_instance_name": hive_instance,
                "commit": config["prod_commit"],
            },
        )
        seq_inject(resource_templates, refs)

    dump_yml(fpath, yml)


def update_operator_yml(operator_name):
    """
    Create the operator_name.yml in data/services/osd-operators/namespaces/{hive_instance} for hive operators
    """
    hive_instances = [
        entry.name
        for entry in os.scandir(os.path.join(SVC_DIR, "namespaces"))
        if entry.is_dir()
    ]
    for hive_instance in hive_instances:
        if hive_instance.startswith("hivep"):
            environment = "production-{}".format(hive_instance)
        elif hive_instance.startswith("hivei"):
            environment = "integration-{}".format(hive_instance)
        elif hive_instance.startswith("hives"):
            environment = "stage-{}".format(hive_instance)
        elif (
            hive_instance == "ssotest01ue1"
        ):  # special case 1. Naming doesn't match convention
            environment = "ssotest01ue1"
        elif hive_instance == "hive-stage-01":  # special case 2.
            environment = "stage-01"
        else:
            print(
                "Unknown hive instance type for {}. Skipping {}".format(
                    hive_instance,
                    os.path.join(
                        SVC_DIR,
                        "namespaces",
                        hive_instance,
                        "{}.yml".format(operator_name),
                    ),
                )
            )
            continue

        write_from_template(
            "operator.tpl",
            os.path.join(SVC_DIR, "namespaces", hive_instance, "%s.yaml"),
            operator_name,
            label="{}",
            hive_instance_name=hive_instance,
            environment=environment,
        )


def prerequisites(args, local_folder=None):
    """
    Prerequisites retrieves a few information on the operator's git repo:
        - It makes sure the repository is public by cloning https://github.com/openshift/{operator_name}
        - It checks if the operator was created with boilerplate
        - It retrieves the latest commit
        - It reads the olm-artifacts-template config to retrieve the managedResourceTypes
    :param args: the scripts arguments
    :param local_folder: Path to local folder for test operator. Used only for testing
    """
    config = {}
    with TemporaryDirectory() as tmp_clone_folder:
        operator_folder = tmp_clone_folder
        if local_folder:
            # Clone the local folder to the temporary directory
            shutil.copytree(local_folder, operator_folder, dirs_exist_ok=True)
            prod_commit = "fake_commit"  # when testing in local, the latest is irrelevant, and might not be available
        else:
            try:
                # Clone the operator repo to a temporary directory
                repo_url = "{}/{}.git".format(GH_OPENSHIFT, args.operator_name)
                repo = Repo.clone_from(repo_url, operator_folder)
                prod_commit = (
                    repo.head.commit
                )  # latest commit to be added to saas-{operator_name}.yaml
            except Exception as e:
                err("Cloning {} failed. Is it public?: ".format(repo_url))

        # Check if operator was created with boilerplate
        if not os.path.isdir(os.path.join(operator_folder, "boilerplate")):
            err(
                "Missing folder {}. The automation only supports operators created with boilerpate".format(
                    os.path.join(operator_folder, "boilerplate")
                )
            )

        # ask if the user wants to use a different commit than the latest one for production
        # we only ask for the commit is the option --prod was passed as parameter of the script
        if args.prod:
            config["prod_commit"] = (
                input(
                    "Please provide commit to deploy to Hive Production. default [{}]".format(
                        prod_commit
                    )
                )
                or prod_commit
            )
        else:
            config["prod_commit"] = None

        # retrieve managedResourceTypes from the hack/olm-registry/olm-artifacts-template.yaml
        olm_tpl_path = os.path.join(operator_folder, OLM_TPL_FILE)
        if not os.path.isfile(olm_tpl_path):
            err("file {} is required for this automation to work".format(OLM_TPL_FILE))

        # using a set guarantees that resources are only declared onces
        olm_tpl = load_yml(olm_tpl_path, skip_format=True)
        config["resource_types"] = {item["kind"] for item in olm_tpl["objects"]}

        if olm_tpl["metadata"]["name"] == "olm-artifacts-template":
            print(
                "Found {} in metadata =>  Hive operator".format(
                    olm_tpl["metadata"]["name"]
                )
            )
            config["operator_type"] = "hive"
        elif olm_tpl["metadata"]["name"] == "selectorsyncset-template":
            print(
                "Found {} in metadata => Cluster operator.".format(
                    olm_tpl["metadata"]["name"]
                )
            )
            config["operator_type"] = "cluster"
        else:
            err(
                "Found {} in metadata. Unsupported OLM template.".format(
                    olm_tpl["metadata"]["name"]
                )
            )

    return config


def main():
    args = parse_args()

    # check prerequisites
    config = prerequisites(args, local_folder=args.local_operator)

    # This will be used to automatically `git add` every file that needs to be committed in the first MR.
    # The remaining files (for the 2nd MR) won't be added. The user can commit them separately
    current_repo = git.Repo(os.getcwd())

    # Add ci-int/jobs file
    write_from_template(
        "ci-int-jobs.tpl",
        os.path.join(CICD_DIR, "ci-int", "jobs-%s.yaml"),
        args.operator_name,
    )
    current_repo.git.add(
        os.path.join(CICD_DIR, "ci-int", "jobs-{}.yaml".format(args.operator_name))
    )

    # Add cicd/saas file
    update_cicd_saas_yml(args.operator_name, config)

    # Add slack permissions
    write_from_template(
        "perms-slack.tpl",
        os.path.join(TEAM_DIR, "permissions", "%s-coreos-slack.yml"),
        args.operator_name,
    )
    current_repo.git.add(
        os.path.join(
            TEAM_DIR, "permissions", "{}-coreos-slack.yml".format(args.operator_name)
        )
    )

    # Add quayRepos and codeComponents entries
    update_app_yml(args.operator_name)
    current_repo.git.add(os.path.join(SVC_DIR, "app.yml"))

    # Add gitlab bundle project request
    update_gitlab_yml(args.operator_name)
    current_repo.git.add(os.path.join("data", "dependencies", "gitlab", "gitlab.yml"))

    # Register the saas file
    update_saas_approver_yml(args.operator_name)

    # Register the slack user group
    update_slack_user_groups_yml(args.operator_name)

    # Add namespace resources: for hive operators only
    if config["operator_type"] == "hive":
        update_operator_yml(args.operator_name)


if __name__ == "__main__":
    main()
