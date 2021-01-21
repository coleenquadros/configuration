# update-qr-tag.sh

This script will automagically gather the latest qontract-reconcile hash 
and prepare an update to app-interface for you.  

Note: adding env var DO_COMMENT with any value will automate the commit

# example output
```
$ make qr-promote
Tag not provided, gathering latest commit
Current Hash (9c9d650) [9c9d650d806c42e82ca881b82fa536c2f4a0dbdd]

    openshift-saas-deploy fix sqs messages (#1337)

New Hash (db99a5e) [db99a5ed51d83b19e8369718797d66a5f5b051e8]

    Dvo insecureskip (#1335)

    o disable ssl_verify in dddb-dvo for accessing prometheus on private clusters

---
Updating envfile (.env)
Updating saasfile (data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml)
Updating jenkinsfile (resources/jenkins/global/defaults.yaml)

diff --git a/.env b/.env
index 70c6c72..fc3646d 100644
--- a/.env
+++ b/.env
@@ -14,7 +14,7 @@ export RECONCILE_REPO=https://github.com/app-sre/qontract-reconcile
 export RECONCILE_IMAGE=quay.io/app-sre/qontract-reconcile
 # replace the above line if quay.io is down
 # export RECONCILE_IMAGE=gcr.io/app-sre/qontract-reconcile
-export RECONCILE_IMAGE_TAG=9c9d650
+export RECONCILE_IMAGE_TAG=db99a5e

 export VAULT_RECONCILE_REPO=https://github.com/app-sre/vault-manager
 export VAULT_RECONCILE_IMAGE=quay.io/app-sre/vault-manager
diff --git a/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml b/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml
index 1699d50..332fb85 100644
--- a/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml
+++ b/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml
@@ -50,7 +50,7 @@ resourceTemplates:
       SLEEP_DURATION_SECS: 600
   - namespace:
       $ref: /services/app-interface/namespaces/app-interface-production.yml
-    ref: 9c9d650d806c42e82ca881b82fa536c2f4a0dbdd
+    ref: db99a5ed51d83b19e8369718797d66a5f5b051e8
     parameters:
       DRY_RUN: --no-dry-run
       GITHUB_API: https://github-mirror.devshift.net
diff --git a/resources/jenkins/global/defaults.yaml b/resources/jenkins/global/defaults.yaml
index ff2d5ff..182c36c 100644
--- a/resources/jenkins/global/defaults.yaml
+++ b/resources/jenkins/global/defaults.yaml
@@ -18,7 +18,7 @@
     white_list_target_branches: '{branch}'
     quay_org: app-sre
     include_path: ''
-    qontract_reconcile_image_tag: '9c9d650'
+    qontract_reconcile_image_tag: 'db99a5e'
     qontract_reconcile_image: 'quay.io/app-sre/qontract-reconcile:{qontract_reconcile_image_tag}'
     # replace the above line if quay.io is down
     # qontract_reconcile_image: 'gcr.io/app-sre/qontract-reconcile:{qontract_reconcile_image_tag}'

If you're satsified, git commit and enjoy!
  git commit -a -m "qontract production promotion 9c9d650 to db99a5e"
```
