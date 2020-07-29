# Deploying Quay Read-Only

Quay can be deployed in a read-only state, which will allow for pulls but disable all write operations. This is typically used during infrastructure migrations, such as moving the database.

## Steps to deploy Quay read-only

### Generate a key pair for the read only instances

1. Checkout the Quay git repo

    ```sh
    git clone git@github.com:quay/quay.git
    ```

1. Install requirements

    ```sh
    pip install -r requirements.txt
    ```

1. Run the `generatekeypair` tool to generate the key pair

    ```sh
    $ PYTHONPATH=. python tools/generatekeypair.py quay-readonly
    Writing public key to quay-readonly.jwk
    Writing key ID to quay-readonly.kid
    Writing private key to quay-read-only.pem
    ```

### Add the read-only key pair to the database

1. Connect to the production database

   - This can be done by launching a pod on the quay cluster with a mysql client.
   - Once connected to the mysql database, select the database to use via:

   ```sql
   use quayapp;
   ```

1. Add the key by running this query:

    NOTE: Expiration date is in the format: `YYYY-MM-DD 00:00:00`

    ```sql
        INSERT INTO servicekey 
          ('name', 'service', 'metadata', 'kid', 'jwk', 'expiration_date')
           VALUES ("quay-readonly",
               "quay",
               "{}",
               "{contents of .kid file}",
               "{contents of .jwk file}",
               "{expiration date of read only}");
    ```

1. Add a key approval by running this query:

    ```sql
    INSERT INTO servicekeyapproval ('approval_type', 'notes')
       VALUES ("Super User API",
               {put notes here on why this is being added});
    ```

1. Set the `approval_id` field on the created `servicekey` row to the `id` field from the created `servicekeyapproval`:

    ```sql
    UPDATE servicekey set approval_id={approval ID} where id={service key id}
    ```

### Update the Quay configuration for readonly

1. Add the created key files into the config bundle in Vault

    Add the contents of `.kid` and `.pem` to 2 separate keys in the `quay-config-secret` secret.  The key names in the secret that are used to store the `.kid` and `.pem` files are what need to be used in the `config.yaml` in the next step.

1. Add the following to the `config.yaml` secret:

    ```yaml
    REGISTRY_STATE: readonly
    INSTANCE_SERVICE_KEY_KID_LOCATION: 'conf/stack/{secret key}.kid'
    INSTANCE_SERVICE_KEY_LOCATION: 'conf/stack/{secret key}.pem'
    ```

## Update read-only expiration time

The quay read-only key has an expiration date, and when that date passes the key will be deactived and be useless.  Before the key expires it's expiration time can be updated in the database.

1. Connect to the quay database

    This can be done by launching a pod on the quay cluster with a mysql client.

   Once connected to the mysql database, select the database to use via:

    ```sql
    use quayapp;
    ```

1. Find the name of the key whose expiration is to be expanded:

    ```sql
    select id,name,expiration_date from servicekey;
    ```

1. Extend the expiration time using the id for the appropriate key by running:

    ```sql
    update servicekey set expiration_date = '<date>' where id = <id>;
    ```

    NOTE: Expiration date is in the format: `YYYY-MM-DD 00:00:00`
