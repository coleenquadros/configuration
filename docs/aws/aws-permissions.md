# How to determine my AWS permissions

Your user file contains a list of `roles`. Each AWS related role contains a list of AWS groups and/or AWS user policies.
To determine what are your permissions, follow the `$ref` to the AWS group or user policy, and read the description field.

For example:

The role `/teams/devtools/roles/f8a-dev-osio-dev.yml` leads to the [corresponding role file](/data/teams/devtools/roles/f8a-dev-osio-dev.yml).
This role file has the user policy `/aws/osio-dev/policies/OwnResourcesFullAccess.yml`, which leads to the [corresponding user policy file](/data/aws/osio-dev/policies/OwnResourcesFullAccess.yml).
This user policy file a description, which explains the permissions allowed by this user policy.
