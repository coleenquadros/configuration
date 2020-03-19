# Deploying Quay Read-Only

Quay can be deployed in a read-only state, which will allow for pulls but disable all write operations. This is typically used during infrastructure migrations, such as moving the database.

## Steps to deploy Quay read-only

### Generate a key pair for the read only instances

1) Checkout the Quay git repo

```sh
git clone git@github.com:quay/quay.git 
```

2) Install requirements

```sh
pip install -r requirements.txt
```

3) Run the `generatekeypair` tool to generate the key pair

```sh
$ PYTHONPATH=. python tools/generatekeypair.py readonly-march-2020
Writing public key to readonly-march-2020.jwk
Writing key ID to readonly-march-2020.kid
Writing private key to readonly-march-2020.pem
```

### Add the read-only key pair to the database

1) Connect to the production database
2) Add the key by running this query:

```sql
INSERT INTO servicekey 
      ('name', 'service', 'metadata', 'kid', 'jwk', 'expiration_date')
       VALUES ("readonly-march-2020",
               "quay",
               "{}",
               {contents of .kid file},
               {contents of .jwk file},
               {expiration date of read only});
```

3) Add a key approval by running this query:

```sql
INSERT INTO servicekeyapproval ('approval_type', 'notes')
       VALUES ("Super User API",
               {put notes here on why this is being added});
```

4) Set the `approval_id` field on the created `servicekey` row to the `id` field from the created `servicekeyapproval`:

```sql
UPDATE servicekey set approval_id={approval ID} where id={service key id}
```

### Update the Quay configuration for readonly

1) Add the created key files into the config bundle in Vault

2) Add the following to the `config.yaml` secret:

```yaml
REGISTRY_STATE: readonly
INSTANCE_SERVICE_KEY_KID_LOCATION: 'conf/stack/{your key name}.kid'
INSTANCE_SERVICE_KEY_LOCATION: 'conf/stack/{your key name}.pem'
```
