# A pgp provided for gpg expired, what to do?


Users can create pgp keys using gpg with an expiration date. User-validator will check for expired keys during any MR build. Thus, expired keys might break any MR checks. Such keys can be excluded from checking by adding them to the USER_VALIDATOR_INVALID_USERS environment variable. You can find it here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/hack/runners.sh#L150

This SOP is assumed to be obsolete with the solution provided by https://issues.redhat.com/browse/APPSRE-4706