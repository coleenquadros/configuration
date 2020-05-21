#!/bin/python3

import argparse
import os
import sys

import oyaml as yaml


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
    try:
        with open(fpath) as f:
            content = f.read()
        return content.format(**subs)
    except Exception as e:
        err(
            "Failed to load and populate template "
            + fpath
            + " with subs "
            + subs
            + "\n"
            + e
        )


def load_yml_tpl(fpath, subs):
    try:
        return yaml.safe_load(load_tpl(fpath, subs))
    except Exception as e:
        err(
            "Failed to load and populate yaml template "
            + fpath
            + " with subs "
            + subs
            + "\n"
            + e
        )


def load_yml(fpath):
    try:
        with open(fpath) as f:
            return yaml.safe_load(f)
    except Exception as e:
        err("Failed to load yaml from %s: %s" % (fpath, e))


def dump_yml(fpath, yml):
    with open(fpath, "w+") as f:
        f.write(yaml.dump(yml, default_flow_style=False))


def inject_from_yml_tpl(chunkname, items, operator_name):

    # Already there?
    # NOTE: this assumes if the operator entry exists, the other entry
    # does too.
    for entry in items:
        if entry["name"] == operator_name:
            print(chunkname + " entries already exist for " + operator_name)
            return

    print("Adding " + chunkname + " entry for " + operator_name)
    new_items = load_yml_tpl(
        os.path.join(TPL_DIR, chunkname + ".yml.tpl"), {"operator_name": operator_name}
    )
    items.extend(new_items)


def update_app_yml(operator_name):
    fpath = os.path.join(SVC_DIR, "app.yml")
    app_yml = load_yml(fpath)

    inject_from_yml_tpl("quayRepos", app_yml["quayRepos"][0]["items"], operator_name)

    inject_from_yml_tpl("codeComponents", app_yml["codeComponents"], operator_name)

    dump_yml(fpath, app_yml)


def update_gitlab_yml(operator_name):
    fpath = os.path.join("data", "dependencies", "gitlab", "gitlab.yml")
    yml = load_yml(fpath)

    projects = yml["projectRequests"][0]["projects"]
    bundle = "saas-%s-bundle" % operator_name

    if bundle in projects:
        print("gitlab project " + bundle + " already in projectRequests.")
        return

    print("Adding gitlab project " + bundle + " to projectRequests.")
    projects.append(bundle)

    dump_yml(fpath, yml)


def update_jobs_yaml(operator_name):
    fpath = os.path.join(CICD_DIR, "ci-ext", "jobs.yaml")
    yml = load_yml(fpath)

    jobs = yml["config"][0]["project"]["jobs"]

    # Already there?
    for job in jobs:
        if job.get("gh-pr-check", {}).get("gh_repo", "") == operator_name:
            print("pr-check entry for " + operator_name + " already exists")
            return

    print("Adding pr-check entry for " + operator_name)
    new_job = load_yml_tpl(
        os.path.join(TPL_DIR, "pr_check_job.yml.tpl"), {"operator_name": operator_name}
    )
    jobs.extend(new_job)

    dump_yml(fpath, yml)


def write_from_template(tplname, destfmt, operator_name, **subs):
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

    # Add quayRepos and codeComponents entries
    update_app_yml(args.operator_name)

    # Add gitlab bundle project request
    update_gitlab_yml(args.operator_name)

    # Register the pr-check job
    update_jobs_yaml(args.operator_name)

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

    write_from_template(
        "roles-saas-approver.tpl",
        os.path.join(TEAM_DIR, "roles", "saas-%s-approver.yml"),
        args.operator_name,
    )


if __name__ == "__main__":
    main()
