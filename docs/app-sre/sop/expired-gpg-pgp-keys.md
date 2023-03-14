# A pgp provided for gpg expired, what to do?

Users can create pgp keys using gpg with an expiration date. If the users uses an expired key, account-notifier can not send the e-mail. Users will receive a message like:

```
Your PGP key on the record has expired and is not valid anymore.
Changing passwords or requesting access to new AWS accounts will no longer work.
Please generate a new one following this guide [1]

Link to userfile: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data%s

[1] https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#generating-a-gpg-key
```

The user needs to create a new PGP key. Account-notifier will then run the reencryption and send the password to the user.
