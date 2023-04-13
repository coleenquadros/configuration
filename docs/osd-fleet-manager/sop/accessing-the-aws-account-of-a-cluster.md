# SOP : OSD Fleet Manager - Accessing the AWS account of a cluster

[toc]

# 1 Introduction

This document defines the steps to execute in order to gain access to the AWS account used by OSD Fleet Manager

## 1.1 Reference Articles

[OSD Fleet Manager integration with AWS Account Operator design doc](https://docs.google.com/document/d/1jna34detfAne2xBVzVz7A0pGUgwi-zZiDrXvJEWwdOY/edit)

## 1.2 Use Cases

The access to the AWS account of a cluster is needed in multiple types of situations such as debugging or cleanup of a stuck cluster.

## 1.3 Success Indicators

N/A

## 1.4 Stakeholders

Internal users

## 1.5 Additional Details

# 2 Procedure

## 2.1 Plan

N/A

## 2.2 Prerequisites

1. Ensure your account is set up for bastion access: <https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/using-bastion-host.md>
1. Ensure you are authorized to read Secrets in the `osd-fleet-manager-aao` namespace of a given Hive cluster (see below)

## 2.3 Execute

1. Locate the corresponding Hive cluster where the FM account pool is defined.
   These clusters are specific to each environment:

    * integration - [hivei01ue1](https://visual-app-interface.devshift.net/clusters#/openshift/hivei01ue1/cluster.yml)
    * stage - [hives02ue1](https://visual-app-interface.devshift.net/clusters#/openshift/hives02ue1/cluster.yml)
    * prod - [hivep01ue1](https://visual-app-interface.devshift.net/clusters#/openshift/hivep01ue1/cluster.yml)

1. Copy and run the SSHUTTLE COMMAND for the given cluster from the corresponding cluster page to create an ssh tunel, e.g.

    ```sh
    sshuttle -r bastion.ci.int.devshift.net 10.164.0.0/16
    ```

1. Open the Console link from the corresponding cluster page and authenticate

1. Obtain the login command for OpenShift CLI and execute it, e.g.

    ````sh
    oc login --token=<REDACTED> --server=https://api.hivei01ue1.f7i5.p1.openshiftapps.com:6443
    ````

1. Obtain the AWS credentials.

    The credentials for a particular cluster are stored in the `osd-fleet-manager-aao` namespace in a secret named `<CLUSTER_ID>-account-creds`, where `CLUSTER_ID` is the identifier of a service or management cluster. The credentials can be extracted using:

    ```sh
    export AWS_ACCESS_KEY_ID=$(oc get secrets ${CLUSTER}-account-creds -o jsonpath='{.data.aws_access_key_id}' | base64 -d)
    export AWS_SECRET_ACCESS_KEY=$(oc get secrets ${CLUSTER}-account-creds -o jsonpath='{.data.aws_secret_access_key}' | base64 -d)
    ```

## 2.4 Validate

Validate that the credentials are correct by executing

```sh
aws sts get-caller-identity
```

## 2.5 Issue All Clear

N/A

# 3 Troubleshooting

N/A

# 4 References

N/A
