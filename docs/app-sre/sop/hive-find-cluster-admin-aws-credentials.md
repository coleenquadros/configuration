Note: The following credentials should only be used in break glass situations

- [How to find a cluster's shard and namespace](#how-to-find-a-clusters-shard-and-namespace)
- [How to find a cluster's kubeadmin credentials in hive](#how-to-find-a-clusters-kubeadmin-credentials-in-hive)
- [How to find a cluster's AWS access key in hive](#how-to-find-a-clusters-aws-access-key-in-hive)
- [How to find a cluster's AWS root credentials in hive](#how-to-find-a-clusters-aws-root-credentials-in-hive)

# How to find a cluster's shard and namespace

1) In the cluster file in app-interface, under `.spec` exists a `provision_shard_id` key. This value is the ID of the Hive shard that holds the cluster and it is automatically populated. The ID should correspond to a `name` in the appropriate clusters-service secret (can be found [here](/data/services/ocm/shared-resources/production.yml) for production).

2) In the cluster file in app-interface, under `.spec` exists an `id` key which is automatically populated. The name of the namespace on the Hive shard is `uhc-<environment>-<id>`. For example, in production, the name of the namespace will be `uhc-production-<id>`.

# How to find a cluster's kubeadmin credentials in hive

1) Find the cluster's shard and namespace according to the [find a cluster's shard and namespace](#how-to-find-a-clusters-shard-and-namespace) section.

1) List the secrets under the cluster namespace and make note of the secrets prefix that looks like *<cluster-name>-<number>-<short-id>-* (ex: quayp03ue1-0-vsscf-admin-kubeconfig)

        oc -n <cluster_ns> get secrets

1) The admin kubeconfig can be found under the *admin-kubeconfig* secret

        oc -n <cluster_ns> get secret/<cluster_prefix>-admin-kubeconfig

        oc -n <cluster_ns> get secret/<cluster_prefix>-admin-kubeconfig -ojson | jq -r '.data.kubeconfig' | base64 -d

    - Note: the above command will output a valid KUBECONFIG file. As such the output can be redirected into a file that can be used like so: `KUBECONFIG=somefile oc <command> <args>`

1) The kubeadmin login credentials can be found under the *admin-password* secret

        oc -n <cluster_ns> get secret/<cluster_prefix>-admin-password

        oc -n <cluster_ns> get secret/<cluster_prefix>-admin-password -ojson | jq -r '.data.kubeconfig' | base64 -d

# How to find a cluster's AWS access key in hive

1) Find the cluster's shard and namespace according to the [find a cluster's shard and namespace](#how-to-find-a-clusters-shard-and-namespace) section.

1) Retrieve the AWS access key from the aws secret

        oc -n <cluster_ns> get secret/aws -ojson | jq -r '.data.aws_access_key_id' | base64 -d
        oc -n <cluster_ns> get secret/aws -ojson | jq -r '.data.aws_secret_access_key' | base64 -d


# How to find a cluster's AWS root credentials in hive

1) Find the cluster's shard and namespace according to the [find a cluster's shard and namespace](#how-to-find-a-clusters-shard-and-namespace) section.

1) Find the accountLink ID from the accountclaim

        oc -n <cluster_ns> get accountclaim <cluster_name> | jq -r '.spec.accountLink'

1) The AWS console access URL can be found in the aws-account-operator namespace under the corresponding accountlink secret

        oc -n aws-account-operator get secret/<accountlink_id>-sre-console-url -ojson | jq -r '.data.aws_console_login_url' | base64 -d

 - Note: this URL has credentials embedded so it MUST NOT be shared in any away.
 - Note: this URL is rotated every hour or so. It is necessary to fetch it again if you get logged out of the console. It sometimes take a few minutes for it to get rotated by the aws-account-operator after it expires
