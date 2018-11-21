import yaml
import io
import sys
import codecs

from jinja2 import Template

users_db = '/home/jmelis/work/git/userdb/osio/users.yaml'

users = yaml.load(io.open(users_db, 'r', encoding="utf-8").read())

TPL = """---
$schema: access/user.yml

labels: {}

name: {{ name }}
{% if github_username %}
github_username: {{ github_username }}
{% endif %}

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
    if not bot_account:
        continue

    keys.extend(user.keys())

    name = user.get('name')
    # redhat_username = user.get('redhat_user')
    github_username = user.get('github_user')
    # quay_username = user.get('quay_user')

    roles = []

    github_orgs = user.get('github_orgs', {})
    if 'rhdt-dev' in github_orgs:
        roles.append('base')

    # vault = user.get('vault', {})
    # if 'devtools-osio' in vault:
    #     roles.append('vault-devtools-osio')

    # if user.get('aws'):
    #     roles.append('aws-analytics')

    # if quay_username:
    #     roles.append('quay-org-openshiftio')

    # clusters = user.get('clusters', {})
    # for key, namespaces in clusters.items():
    #     for namespace in namespaces:
    #         if key == 'dsaas':
    #             key = 'production-view'
    #         else:
    #             key = 'staging-edit'

    #         roles.append("openshift/{}-{}".format(key, namespace))

    if not roles:
        continue

    try:
        user_yaml = user_template.render(
            name=name,
            github_username=github_username,
            roles=roles
        )
    except KeyError:
        print "KEYERROR"
        print user
        sys.exit(1)

    with codecs.open("../bots/{}.yml".format(name), "w", "utf-8") as f:
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
