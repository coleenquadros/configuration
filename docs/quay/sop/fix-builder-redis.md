# Builds are not starting

## Diagnosing the issue

If no builds are running:

### Check the build queue

Run the following query in the database:

```
use quay;
select * from queueitem where queue_name like 'dockerfilebuild/%' and available=1 and retries_remaining > 0 and processing_expires > now();
```

If there are *many* builds and their `available_at` *keeps moving forward*, you likely have a Redis lockup.

### Check build manager logs

Check the build manager logs for statements like this:

`builder[102]: 2020-07-17 16:26:06,439 [102] [WARNING] [buildman.manager.ephemeral] Job: 1b93a26c-2f99-4687-a2dd-bba7e04b13aa already exists in orchestrator, timeout may be misconfigured`

If so, its likely Redis is filled with builds that are no longer running, and it is preventing new builds from being run.


## Fixing the issue

To fix this issue, all the existing keys within Redis must be flushed via the `FLUSHALL` command.

### Steps to fix

The Redis we use is an ElasticCache behind the `QuayVPC` VPC, which means it can only be accessed via the QuayVPC bastion host. *Further*, the Redis is run behind TLS termination, which means *redis-cli will not work without a proxy*. For that reason, it is likely easier to fix this problem as follows:

1) SSH into the `QuayVPC` bastion host, whose IP can be found in the AWS EC2 console under the name `QuayVPC`
2) Run a docker container with ubuntu and install the necessary tools:

```sh
docker run -ti ubuntu

$ apt-get update
$ apt-get install -y emacs python python-pip
$ pip install redis
```

3) Add the following code into a local file, replacing the section `redispasswordhere` with the actual Redis password:

```python
import redis

args = {
    "host": "master.quayio-production.qcfv1o.use1.cache.amazonaws.com",
    "password": "redispasswordhere",
    "ssl": True,
}
redis_client = redis.StrictRedis(**args)
redis_client.flushall()
```

4) Run the script to flush all the keys from Redis:

```sh
python fix-redis.py
```
