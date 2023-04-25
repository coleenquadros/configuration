#### Print out Jenkins jobs configurations

In order to get the configurations in a human-friendly way, [qontract-reconcile](https://github.com/app-sre/qontract-reconcile) can print out Jenkins Jobs configurations in JSON format.

1. **Run qontract-server**

In `app-interface` directory, run `make server` command.

Your Qontract GraphQL server will available at `http://localhost:4000/graphql`

2. **Setup qontract-reconcile**

In order to use this tool, the easiest option is to use pip to install `qontract-reconcile`.

Clone [qontract-reconcile](https://github.com/app-sre/qontract-reconcile).

```sh
$ pip install --user qontract-reconcile --upgrade --pre
```

3. **Configure qontract-reconcile**

Create a `config.debug.toml` file in `qontract-reconcile` directory
```
[graphql]
server = "http://localhost:4000/graphql"
```

Setting environment variable(required by integration but will not used in print-only mode)
```sh
export APP_INTERFACE_STATE_BUCKET=app-interface
export APP_INTERFACE_STATE_BUCKET_ACCOUNT=app-sre
```

4. **Run the Integration**

Run `qontract-reconcile --config config.debug.toml --dry-run jenkins-job-builder --print-only` will print out all the jobs defined in app-interface.

Following filters can help to limit the output scope.

Use `--config-name` to print out jobs defined in the exact config file and generate xml file in 'throughput/jjb/printout'

Example for jobs defined in [config](/data/services/github-mirror/cicd/build.yaml):
```sh
$ qontract-reconcile --config config.debug.toml --dry-run jenkins-job-builder --print-only --config-name ci-ext-github-mirror-jobs
```

Use `--job-name` to print out jobs match with job-name
Example:
```sh
$ qontract-reconcile --config config.debug.toml --dry-run jenkins-job-builder --print-only --job-name app-sre-github-mirror-gh-build-master
```
