# AppSRE Onboard Setting

## Overview

This SOP explains how to setup a local development environment for app-interface. This environment includes the following components:

1. app-interface - this is the prod data repository. you can think of it as our database.
1. app-interface-dev-data - this is data we use for safe development.
1. qontract-schemas - this is the repository that defines what the data should look like.
1. qontract-server - this is the component that exposes the data from app-interface.
1. qontract-reconcile - this is the main component that acts on data from app-interface.

This guide assums that you are setting up a development environment to use with the real [app-interface](https://gitlab.cee.redhat.com/service/app-interface) data.

## Install basic tools (MacOs, optional)

If you are running MacOs, you may want to install the GNU version of some common tools like grep, coreutils, find, awk or sed. They are availbale with homebrew, for instance:

``` shell
brew install findutils
```
and perhaps make your brew-installed tools override the default MacOs ones.


## Setup Repo

1. Fork the following repositories:
    * [app-interface](https://gitlab.cee.redhat.com/service/app-interface)
    * [app-interface-dev-data](https://gitlab.cee.redhat.com/app-sre/app-interface-dev-data.git)
    * [qontract-server](https://github.com/app-sre/qontract-server)
    * [qontract-reconcile](https://github.com/app-sre/qontract-reconcile)
    * [qontract-schemas](https://github.com/app-sre/qontract-schemas)
1. Clone the repositories from your forks:

    ```sh
    $ mkdir dev && cd dev
    $ git clone git@github.com:<github_username>/qontract-server ./app-sre/qontract-server  
    $ git clone git@github.com:<github_username>/qontract-reconcile ./app-sre/qontract-reconcile  
    $ git clone git@github.com:<github_username>/qontract-schemas ./app-sre/qontract-schemas  
    $ git clone git@gitlab.cee.redhat.com:<redhat_username>/app-interface ./service/app-interface
    $ git clone git@gitlab.cee.redhat.com:<redhat_username>/app-interface-dev-data ./service/app-interface-dev-data
    ```

1. Make sure your file directory is the same as following:

    ```sh
    $ tree -L 2
    .
    ├── app-sre
    │   ├── qontract-reconcile
    │   ├── qontract-schemas
    │   └── qontract-server
    └── service
        └── app-interface
        |-- app-interface-dev-data
    6 directories, 0 files
    ```

## Setup qontract-schemas

1. Nothing to do here!

Note that when running `make dev` in qontract-server, it will use the schemas in the cloned directory.

This allows local development of schemas and logic (qontract-reconcile).

> Optionally, if you want to specify the path for the qontract-schemas repo on your local filesystem, you can use the parameter:
>\*  `SCHEMAS_PATH` - (optional) path to a local qontract-schemas repo (Default: `$PWD/../qontract-schemas`)

## Setup qontract-server

1. Install [docker](https://www.docker.com/products/docker-desktop).
1. To start a development server, run the following command in the `qontract-server` directory:

    ```sh
    $ make dev
    ```

Your Qontract GraphQL server will be available at `http://localhost:4000/graphql`

## Setup qontract-reconcile

1. Install python3 and [virtualenv](https://virtualenv.pypa.io/en/latest/installation.html).
1. In `qontract-reconcile` directory, create and enter the virtualenv environment:

    ```sh
    $ python3 -m venv venv
    $ source venv/bin/activate
    # make sure you are running the latest setuptools
    $ python3 -m pip install --upgrade pip setuptools
    ```

3. Install development packages:

    ```sh
    $ python3 setup.py develop
    ```

## Configure qontract-reconcile

1. Generate a new Github [Personal access tokens](https://github.com/settings/tokens) for [Vault](https://vault.devshift.net) access. Only `read:org` is required for scopes.
1. Make sure to copy and save the new personal access token right after generation. You won’t be able to see it again!
1. Sign in to Vault with Github Token. Copy the value of `data_base64` in [ci-int/qontract-reconcile-toml](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml).
1. Decode the content to create a `config.debug.toml` file in `qontract-reconcile` directory with command `echo <content> | base64 -d > config.debug.toml`
1. Set graphql server in `config.debug.toml` to `http://localhost:4000/graphql`.

## Run an integration locally

### Inside your environment

```sh
$ cd qontract-reconcile
$ qontract-reconcile --config config.debug.toml --dry-run --log-level DEBUG <integration-name>
```

### Inside docker

```sh
make dev-reconcile-loop dev-reconcile-loop INTEGRATION_NAME=<integration-name> DRY_RUN=<--dry-run|--no-dry-run> INTEGRATION_EXTRA_ARGS=<integration-args> SLEEP_DURATION_SECS=<natural number>
```

## Using development data

We are trying to move towards using development data when doing development work. This is currently hard because to perform development we need data, which has to be created.

This [repository](https://gitlab.cee.redhat.com/app-sre/app-interface-dev-data) contains development data that can be used as is for `qontract-server`.
The repository also has a [sanitization make target](https://gitlab.cee.redhat.com/app-sre/app-interface-dev-data#sanitizing-data-for-public-example-repository) to convert the data for public purposes.
If you change/add new data in that repository, also make sure to adjust the sanitization method.

It is encouraged that development work is done using this repository and not using the [real data](https://gitlab.cee.redhat.com/service/app-interface).

1. To start a development server with the data from the development app-interface, run the following command in the `qontract-server` directory:

    ```sh
    $ cd qontract-server
    $ APP_INTERFACE_PATH=$PWD/../app-interface make dev
    ```

1. Sign in to Vault and copy the content of [app-interface-dev-config-toml](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-dev-config-toml) into a file called `config.dev.toml`.

1. Run an integration:

    ```sh
    $ cd qontract-reconcile
    $ qontract-reconcile --config config.dev.toml --dry-run --log-level DEBUG <integration-name>
    ```

## Creating a new integration

An integration is **any** piece of software that has the following properties:

- Its goal is to configure a third-party service or tool to match whatever is defined in the app-interface datafiles.
- It can query a running `qontract-server` using a GraphQL client library to obtain the DESIRED state.
- It can retrieve the CURRENT state by using APIs or whatever technique of the third-party service that needs to be configured.
- Capable of diffing the CURRENT and DESIRED state.
- It can perform any required actions to evolve the CURRENT state into the DESIRED state.
- Supports `--dry-run` option (or similar) to simulate any changes without applying them.
- It MUST be developed using IDEMPOTENCY principles, so if the integration is run several times, it will not fail.

## Managing remote best practices

Manage your remote repo as following to avoid confusion of "origin"

```sh
$ git remote -v
<redhat_username>   git@gitlab.cee.redhat.com:<redhat_username>/app-interface.git (fetch)
<redhat_username>   git@gitlab.cee.redhat.com:<redhat_username>/app-interface.git (push)
upstream	git@gitlab.cee.redhat.com:service/app-interface (fetch)
upstream	git@gitlab.cee.redhat.com:service/app-interface (push)
```

To keep your repo up to date:

```sh
$ git pull upstream master && git push <redhat_username> master
```
