import yaml
import io
import sys
import codecs

from jinja2 import Template

users_db = '/home/jmelis/work/git/userdb/osio/users.yaml'

users = yaml.load(io.open(users_db, 'r', encoding="utf-8").read())

TPL = """---
$schema: access/user-1.yml

labels: {}

name: {{ name }}
redhat_username: {{ redhat_username }}
github_username: {{ github_username }}

roles:
{% for role in roles %}
- $ref: services/openshift.io/roles/{{ role }}.yml
{% endfor %}
"""

toggles_staging = ["aazores", "ajolicoe",
                   "aknutsen", "alkazako",
                   "bmajsak", "ckrych",
                   "cvogt", "ibuziuk",
                   "jakumar", "jowilson",
                   "kpiwko", "mloriedo",
                   "nmukherj", "ogaragat",
                   "pbergene", "rhopp",
                   "rorai", "shbose",
                   "slemeur", "sudsen",
                   "viraj", "xcoulon"]

toggles_prod = ["aknutsen", "xcoulon",
                "shbose", "mloriedo",
                "alkazako", "bmajsak",
                "jowilson", "rhopp",
                "ckrych", "ibuziuk",
                "slemeur", "ogaragat",
                "nmukherj", "viraj",
                "aazores", "ajolicoe",
                "jakumar", "rorai",
                "cvogt", "pbergene"]



user_template = Template(TPL, trim_blocks=True, lstrip_blocks=True)

keys = []
for user in users:
    bot_account = user.get('bot_account')
    if bot_account:
        continue

    keys.extend(user.keys())

    name = user.get('name')
    redhat_username = user['redhat_user']
    github_username = user.get('github_user')
    if not github_username:
        print "Skipping %s because no github_username." % (redhat_username,)
        continue

    quay_username = user.get('quay_user')

    roles = []

    # github_orgs = user.get('github_orgs', {})
    # if 'rhdt-dev' in github_orgs:
    #     roles.append('base')

    vault = user.get('vault', {})
    if 'devtools-osio' in vault:
        roles.append('lead')

    if user.get('aws'):
        roles.append('bayesian-dev')

    if quay_username:
        roles.append('quay-org-openshiftio')

    clusters = [i for l in user.get('clusters', {}).values() for i in l]
    print([redhat_username, clusters])

    if 'dsaas-production' in clusters or 'dsaas-preview' in clusters:
        roles.append('dsaas-dev')

    if 'dsaas-keycloak' in clusters or 'dsaas-keycloak-preview' in clusters:
        roles.append('dsaas-keycloak-dev')

    if 'bayesian-production' in clusters or 'bayesian-preview' in clusters:
        if 'bayesian-dev' not in roles:
            roles.append('bayesian-dev')

    if 'launchpad-production' in clusters or 'launchpad-dev' in clusters:
        roles.append('launchpad-dev')

    if 'hdd-preview' in clusters or 'hdd-production' in clusters:
        roles.append('hdd-dev')

    if redhat_username in toggles_prod:
        roles.append('toggles-production')

    if redhat_username in toggles_staging:
        roles.append('toggles-staging')

    if not roles:
        print "Skipping %s because no roles." % (redhat_username,)
        continue

    try:
        user_yaml = user_template.render(
            name=name,
            github_username=github_username,
            redhat_username=redhat_username,
            quay_username=quay_username,
            roles=roles
        )
    except KeyError:
        print "KEYERROR"
        print user
        sys.exit(1)

    with codecs.open("{}.yml".format(redhat_username), "w", "utf-8") as f:
        f.write(user_yaml)

    # print(user_yaml)
    # if not bot_account:
    #     try:
    #         redhat_username = user['redhat_user']
    #         name = user['name']
    #         github_username = user['github_user']
    #     except:
    #         continue

    #     print("  - $ref: /users/{}.yml".format(redhat_username))
