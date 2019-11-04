# Restoring git repo from git-keeper backup

To restore git repo you need to have:
- Access to S3 bucket containing backups
- GPG key for decrypting backups

## Downloading backup

All APP-SRE team members should have access to [Prod S3 bucket](https://s3.console.aws.amazon.com/s3/buckets/git-keeper-production/)

We are doing backups every day but they are stored for different period of time because of different retention policies.
If you can't find needed backup in daily folder please look at weekly or monthly folder.

## Obtaining GPG key for decrypting

You can find private GPG key for decryptyng backups [here](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/repobackups)
You need to import it like
```
gpg --import <key>
gpg --list-keys
```

## Decrypt backup
```
gpg -d git-keeper.git.tar.gpg | tar xvf -
```
After having backup decrypted and untared we can `cd` to some location and clone to working tree to inspect like:
```
git clone ../04/workdir/git-keeper.git/
```

Or restore to remote location
```
cd workdir/git-keeper.git
```
You can push that repo to other remote location, just make sure repo is already exists:
```
git remote set-url --push origin git@github.com:username/mirrored.git
git push
```

