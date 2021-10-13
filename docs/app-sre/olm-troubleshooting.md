- [OLM Dance](#olm-dance)
  - [Manual Steps](#manual-steps)
  - [Using Script](#using-script)
    - [Dry Run](#dry-run)
    - [Do the Dance](#do-the-dance)
  - [Trigger the saas deploy job](#trigger-the-saas-deploy-job)
- [OLM catalog (registry) troubleshooting](#olm-catalog-registry-troubleshooting)

# OLM Dance

The OLM "dance" is when you delete the CSV and the Subscription and redeploy with the saas job. It is safe to do so.

## Manual Steps

```sh
oc project <project_name>
oc delete catalogsource <name>
oc delete subscription <name>
oc delete csv <name>
```

Trigger the saas deploy job. See: [Trigger the saas deploy job](#trigger-the-saas-deploy-job)

## Using Script

Run the [olm-dance.sh](olm-dance.sh) script from your machine.

### Dry Run

```sh
./olm-dance.sh -n <namespace> -s <subscription>
```

### Do the Dance

Adding `-d` will enable delete mode

```sh
./olm-dance.sh -n <namespace> -s <subscription> -d
```

Example Output:

```sh
Deteting subscription: hive
subscription.operators.coreos.com "hive" deleted
Deteting subscription: hive-catalog
catalogsource.operators.coreos.com "hive-catalog" deleted
Deteting subscription: hive
operatorgroup.operators.coreos.com "hive-og" deleted
Deteting CSV: hive-operator.v0.1.2202-sha86cd1c9
clusterserviceversion.operators.coreos.com "hive-operator.v0.1.2202-sha86cd1c9" deleted
Deteting CSV: hive-operator.v0.1.2257-sha0f9c2b4
clusterserviceversion.operators.coreos.com "hive-operator.v0.1.2257-sha0f9c2b4" deleted
Deteting CSV: hive-operator.v0.1.2274-sha0e29757
clusterserviceversion.operators.coreos.com "hive-operator.v0.1.2274-sha0e29757" deleted
```

Trigger the saas deploy job. See: [Trigger the saas deploy job](#trigger-the-saas-deploy-job)

## Trigger the saas deploy job

- Find the service which has the operator you want to redeploy here https://visual-app-interface.devshift.net/services
- Find the pipeline for the service/operator which you want to redeploy under the `Saas Files` section of the service details page
- Clicking the pipelinerun in visual-app-interface will take you to the Tekton Pipeline on the CI cluster
- Search for the latest run
- Click the 3-dots menu on the right of the job and click  ̀Rerun`

# OLM catalog (registry) troubleshooting

̀`hive` is used as an example here. Substitute names as needed.

1. rsh into the catalog prod

    ```sh
    oc -n hive rsh hive-catalog-fg8h6
    ```

1. Download grpcurl into the container

    ```sh
    cd /tmp
    wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.0/grpcurl_1.8.0_linux_x86_64.tar.gz
    tar xvf grpcurl_1.8.0_linux_x86_64.tar.gz grpcurl
    rm grpcurl_1.8.0_linux_x86_64.tar.gz
    ```

1. List the packages that are exposed by the registry

    ```sh
    ./grpcurl -plaintext localhost:50051 api.Registry/ListPackages
    ```

    Example output
    ```
    {
      "name": "hive-operator"
    }
    ```

1. Show information about a package (channels, default channel, csv name)

    This is mainly used to verify if a package exists, what the available channels are, the default channel and what the latest CSVs are

    ```sh
    ./grpcurl -plaintext -d '{"name":"hive-operator"}' localhost:50051 api.Registry/GetPackage
    ```

    Example output
    ```
    {
      "name": "hive-operator",
      "channels": [
        {
          "name": "staging",
          "csvName": "hive-operator.v0.1.2660-sha743e047"
        }
      ],
      "defaultChannelName": "staging"
    }
    ```


1. Get the bundle for the desired channel

    This tests that the desired package is available in the desired channel. The output will be the actual bundle and is typically very long 

    ```sh
    ./grpcurl -plaintext -d '{"pkgName":"hive-operator","channelName":"staging"}' localhost:50051 api.Registry/GetBundleForChannel
    ```

1. Find package that replaces currently deployed csv

    Using `oc get subscription,installplan,csv` we can find out what the currently deployed CSV is and then query the registry to ask what CSV replaces it, if any

    ```sh
    ./grpcurl -plaintext -d '{"csvName":"hive-operator.v0.1.2928-shac6ca3dd","pkgName":"hive-operator","channelName":"production"}' localhost:50051 api.Registry/GetBundleThatReplaces
    ```
