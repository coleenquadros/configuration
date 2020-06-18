#!/usr/bin/env python3

import argparse
import os
import sys

from ruamel.yaml import YAML


yaml = YAML()
# Keep (redundant) quotes around keys and non-special values
yaml.preserve_quotes = True
# `---` at top of files (though all are single documents at the moment)
yaml.explicit_start = True

TPL_DIR = os.path.join("hack", "new_osd_operator")
SVC_DIR = os.path.join("data", "services", "osd-operators")
TEAM_DIR = os.path.join("data", "teams", "sd-sre")
CICD_DIR = os.path.join(SVC_DIR, "cicd")


def parse_args():
    parser = argparse.ArgumentParser(description="Register a new OSD operator.")
    parser.add_argument("operator_name", help="The name of the operator to register.")
    return parser.parse_args()


def err(msg):
    print(msg, file=sys.stderr)
    sys.exit(-1)


def load_tpl(fpath, subs):
    """Loads and interpolates a template file containing {format} placeholders,
    returning it as a string.
    """
    try:
        with open(fpath) as f:
            content = f.read()
        if subs:
            return content.format(**subs)
        # This is a little weird: it accounts for loading non-template YAMLs containing empty dicts
        return content.format("{}")
    except Exception as e:
        err(
            "Failed to load and populate template "
            + fpath
            + " with subs "
            + str(subs)
            + "\n"
            + e
        )


def load_yml(fpath, subs=None):
    """Loads and interpolates a template file containing {format} placeholders,
    interprets it as YAML, and returns the resulting dict.
    """
    try:
        return yaml.load(load_tpl(fpath, subs))
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


def main():
    args = parse_args()

    # Add ci-int/jobs file
    write_from_template(
        "ci-int-jobs.tpl",
        os.path.join(CICD_DIR, "ci-int", "jobs-%s.yaml"),
        args.operator_name,
    )

    # Add cicd/saas file
    write_from_template(
        "cicd-saas.tpl",
        os.path.join(CICD_DIR, "saas", "saas-%s.yaml"),
        args.operator_name,
    )

    # Add namespace files for stage/int/prod
    for level in ("stage", "integration", "production"):
        write_from_template(
            "namespace.tpl",
            os.path.join(SVC_DIR, "namespaces", "%s-" + level + ".yml"),
            args.operator_name,
            level=level,
        )

    # Add slack permissions
    write_from_template(
        "perms-slack.tpl",
        os.path.join(TEAM_DIR, "permissions", "%s-coreos-slack.yml"),
        args.operator_name,
    )

    # Add quayRepos and codeComponents entries
    update_app_yml(args.operator_name)

    # Add gitlab bundle project request
    update_gitlab_yml(args.operator_name)

    # Register the pr-check job
    update_jobs_yaml(args.operator_name)

    # Register the saas file
    update_saas_approver_yml(args.operator_name)

    # Register the slack permissions file
    update_slack_roles_yml(args.operator_name)

    # Register the slack user group
    update_slack_user_groups_yml(args.operator_name)


if __name__ == "__main__":
    main()
