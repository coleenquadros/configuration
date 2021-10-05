# OCM Quay mirroring

## Background

This is a document describing how mirroring is done into ocm-quay, along with some additional required information

## How does mirroring work?

Mirroring of images to ocm-quay is done by an integration called `quay-mirror-org`: https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/quay_mirror_org.py

This integration mirrors entire Quay organizations.

The mirrored orgs can be found here: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/dependencies/ocm-quay

Note: For an org to be mirrored, it's repositories have to be managed via app-interface.

## Mirroring of OpenShift release images

The images from the `openshift-release-dev` org are mirrored by an integration called `ocp-release-mirror`: https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/ocp_release_mirror.py

This integration mirrors the two repositories of this organization: `ocp-release` and `ocp-v4.0-art-dev`.

This integration takes it's configuration from: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/app-interface/ocp-release-mirror-1.yml

## Logging into ocm-quay (AppSRE only)

ocm-quay URLs:
* read/write: https://push.q1w2.quay.rhcloud.com
* read: https://pull.q1w2.quay.rhcloud.com

Credentials can be found in Vault: https://vault.devshift.net/ui/vault/secrets/app-interface/show/ocm-quay/common/adminuser
