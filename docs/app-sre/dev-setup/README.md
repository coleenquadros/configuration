# AppSRE Onboard Setting

## Setup Repo

1. Fork [app-interface](https://gitlab.cee.redhat.com/service/app-interface), [qontract-server](https://github.com/app-sre/qontract-server/), [qontract-reconcile](https://github.com/app-sre/qontract-reconcile).
1. Clone the repo from your fork repo.

```sh
$ mkdir dev && cd dev
$ git clone git@github.com:<github_username>/qontract-server ./app-sre/qontract-server  
$ git clone git@github.com:<github_username>/qontract-reconcile ./app-sre/qontract-reconcile  
$ git clone git@gitlab.cee.redhat.com:<redhat_username>/app-interface ./service/app-interface
```

Make sure your file directory is the same as following:

```sh
$ tree -L 2
.
├── app-sre
│   ├── qontract-reconcile
│   └── qontract-server
└── service
    └── app-interface
5 directories, 0 files
```


Best Practice: manage your remote repo as following to avoid confusion of "origin"

> ```sh
> $ git remote -v
> <redhat_username>	git@gitlab.cee.redhat.com:<redhat_username>/app-interface.git (fetch)
> <redhat_username>	git@gitlab.cee.redhat.com:<redhat_username>/app-interface.git (push)
> upstream	git@gitlab.cee.redhat.com:service/app-interface (fetch)
> upstream	git@gitlab.cee.redhat.com:service/app-interface (push)
> ```
> To keep your repo up to date:
> ```sh
> $ git pull upstream master && git push <redhat_username> master
> ```

## Setup qontract-server

1. Install [docker](https://www.docker.com/products/docker-desktop).
1. In `app-interface` directory, run `make server` command.

> Optionally, if you want to specify the path for the app-interface repo on your local filesystem, you can use the parameter:
>*  `APP_INTERFACE_PATH` - (optional) path to a local app-interface repo (Default: `$PWD/../../service/app-interface`).

Your Qontract GraphQL server will available at `http://localhost:4000/graphql`

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

## Run an Integration

```sh
$ cd qontract-reconcile
$ qontract-reconcile --config config.debug.toml --dry-run --log-level DEBUG <integration-name>
# review output and run without `--dry-run` to perform actual changes
$ qontract-reconcile --config config.toml --log-level INFO <integration-name>
```
