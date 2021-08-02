# Quick start guide on accessing OpenShift v4 clusters

## Table of Contents

* [Initial setup](#initial-setup)
  * [ocm](#ocm)
  * [oc and kubectl](#oc-and-kubectl)
  * [More info (staging environment, etc.)](#more-info-staging-environment-etc)
* [Logging in to a cluster](#logging-in-to-a-cluster)
  * [CLI](#cli)
  * [Web Console](#web-console)
This is a quick getting-started guide that is relevant as a pre-requisite to responding to alerts.

## Initial setup

### ocm

Install OCM CLI, if it's not installed already. Or update it prior to starting on-call shift.

```
go get -u github.com/openshift-online/ocm-cli/cmd/ocm
```

Get your [offline access token](https://console.redhat.com/openshift/token).

Note that you need to use your `<kerberos_id>+sd-app-sre` ID to be able to log in and see all our clusters

Log into OCM.
```
ocm login --token <longTokenString>
```

### oc and kubectl

The [oc](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html#cli-installing-cli_cli-developer-commands) latest build can be found [here](https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/).

In case [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) was not part of the _tarball_ for your OS, the easiest way is to just symlink to `oc`:

```bash
ln -s -T `which oc` ~/bin/kubectl
```

Alternatively, you can fetch it by following the [upstream instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/).


### More info (staging environment, etc.)

You can find more ocm related info under [/v4/howto/ocm.md](/v4/howto/ocm.md).

## Logging in to a cluster

Find the FQDN of the cluster in the alert. It will be in the format:

```
<TRUNCATED_CLUSTERNAME>.foo.bar.openshiftapps.com
```

The TRUNCATED_CLUSTERNAME can be used for finding the full CLUSTERNAME (second column) and CLUSTERID (first column), by running the following command:

```
ocm cluster list <TRUNCATED_CLUSTERNAME>
```

(If a cluster name is short enough, there will be nothing to truncate, in which case TRUNCATED_CLUSTERNAME==CLUSTERNAME.)

If the command takes too long, try passing the `--managed` flag:

```
ocm cluster list --managed | grep <TRUNCATED_CLUSTERNAME>
```

An alternative is browsing at https://console.redhat.com/openshift and use the _Filter_ field.

### Web Console

1. Run the following command:
    ```
    ocm cluster login --console <CLUSTERNAME|CLUSTERID>
    ```
2. In your newly–opened browser tab, select OpenShift SRE auth link.
3. Log in using your standard Red Hat 2fa credentials.


### CLI

With the new changes to utilize Google Auth for SREs, we now need to log in through the Web Console and request a token through that to log in with the CLI.

1. Follow the [Web Console](#web_console) instructions above.
2. Once you log in, click on your Name in the Top Right corner and select the "Copy Login Command" link.
3. This will ask you to log in as OpenShift SRE again, similar to before.
4. Click on "Display Token"
5. Copy the `oc login ...` command and paste that into your terminal window.

You should now be logged into the cluster.

## General troubleshooting

Check the alert runbook link for advice specific to the alert.
