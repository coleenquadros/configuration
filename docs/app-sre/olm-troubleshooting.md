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
