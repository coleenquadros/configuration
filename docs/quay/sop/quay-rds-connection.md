# Quay.io RDS Connection SOP

## Get the database cred

The database host url can be obtained from the only `-rds` secret in the `quay` namespace:

```shell
$ oc get -n quay secret|grep -- -rds
```

Run following command with the correct rds name:

```shell
$ oc get secret <rds secret name> -o json | jq -r '.data."db.host"|@base64d'
```
Note this output down, we will refer to it as `<db_host>`

The database password can be obtained from the `quay-config-secret` secret:

```shell
$ oc get -n quay secret|grep quay-config-secret
```

From the list of all `quay-config-secret`, run following command with the latest version name of `quay-config-secret`:

```shell
$ oc get secret <quay-config-secret name> -n quay -o json|jq -r '.data."config.yaml"|@base64d'|grep DB_URI|head -1|cut -d':' -f4|cut -d'@' -f1|python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));"
```

Note this output down, we will refer to it as `<db_password>`


## Get connection into rds

Create a `diag-container` pod in the `app-sre` namespace (if it doesn't already exist):

```shell
$ oc new-project app-sre
$ oc new-app https://github.com/app-sre/diag-container
$ oc rsh <diag-container-pod-name>

# now in the diag-container
$ export DB_HOST=<db_host>
```

Use mysql client to connect to rds:

```shell
# now in the debug-container
$ export DB_HOST=<db_host>
$ mysql -u quayio -h $DB_HOST -p
# copy paste `<db_password>` here
Enter password:
...
mysql> 

```

Now you are able to run mysql sql in the RDS.

Remember to delete the pod in the end.
```shell
$ oc delete pod -n quay debug-container
```
