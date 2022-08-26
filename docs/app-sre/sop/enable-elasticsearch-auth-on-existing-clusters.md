# Enabling Elasticsearch Authentication on existing Clusters

Context: [APPSRE-3409](https://issues.redhat.com/browse/APPSRE-3409)

Lets assume we want to enable authentication on an existing ES domain `my-domain` in AWS account `my-account`

1. Disable terraform integration for `my-account`
2. Manually [enable authentication](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-enabling) in AWS according to customer needs (user/pass or user arn). Note, that you can also allow a migration period (advised for prod accounts).
3. Add authentication section to ES defaults in app-interface

```yaml
# Note, that you can currently also use advanced_security_options.
# However, advanced_security_options will be replaced by auth block, because
# for compliance reasons we will enforce certain security options.
auth:
  admin_user_credentials:
    path: <vault-path>
    version: <secret-version>
```

OR

```yaml
auth:
  admin_user_arn: my-arn
```

Example in [dev-data](https://gitlab.cee.redhat.com/app-sre/app-interface-dev-data/-/blob/main/resources/terraform/elasticsearch/elasticsearch-1.yml#L41-44)

4. Enable terraform integration for `my-account`

## Tested Scenarios

1. switching between master_arn and user/pass -> no problem. Instant change
2. removing security block from tfconfig.json -> no problem -> keeps current real-world settings
3. Set fine-grained access manually: cluster goes red (degraded) and starts a migration process -> ~30min
4. Enable fine-grained security via terraform: cluster being deleted and created -> we do not want that.

## Further Findings

### Access Control changes affect cluster status

Changing an existing clusters access control results in the cluster state being red for transition period ~30min. During that transition period the cluster is still reachable, however, it likely has limited capabilities.

### Enabling Fine Grained Security through terraform will re-create the domain

Enabling the fine-grained security block through terraform will result in the resource being re-created. This must be avoided on existing clusters, as it results in data loss. Potentially this means, that fine-grained security should be enabled outside of terraform.
See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain#advanced_security_options

### Migration Period Feature

Opensearch offers a migration period window of 30 days when enabling fine-grained security. This might come in handy for existing clusters. https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html#fgac-enabling
