---
$schema: /access/role-1.yml

labels: {{}}
name: saas-{operator_name}-approver

permissions:
- $ref: /teams/sd-sre/permissions/{operator_name}-coreos-slack.yml

owned_saas_files:
- $ref: /services/osd-operators/cicd/saas/saas-{operator_name}.yaml
