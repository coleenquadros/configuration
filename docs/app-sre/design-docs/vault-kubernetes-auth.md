# Design doc: Vault Kubernetes Authentication

## Author/date
dwelch / February 2023


## Tracking JIRA
https://issues.redhat.com/browse/APPSRE-7074


## Problem Statement
AppSRE applications within Openshift clusters rely on static approle credentials for authenitication to vault. These credentials are not routinely rotated, and in many cases, do not expire. 

Given the numerous security and operational challenges presented by static tokens in our secret management offering, a solution is needed that improves our security posture, improves audit redability, reduces engineer toil, and increases sophistication of the offering.

## Context

Currently, approle creds stored within kubernetes secrets are mounted into pods as environment variables. 

For example, the same set of credentials for the `app-interface` vault approle are utilized within QR integrations hosted on `appsres03ue1` and `appsrep05ue1` (same creds are also utilized by ci.int but outside of scope for this design doc. see [APPSRE-6932](https://issues.redhat.com/browse/APPSRE-6932)). These credentials do not expire. 
In order to rotate, an AppSRE member must: 
* manually delete the `secret_id` off the approle
* generate a new `secret_id`
* update [app-interface/app-sre/app-interface-production/qontract-reconcile-toml](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/qontract-reconcile-toml)
* update [app-sre/ci-int/qontract-reconcile-toml](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml)
    * ensure `data_base64` is also regenerated

Leveraging kubernetes authentication, the following benefits are achieved:
* automated credential recycling
    * the necessary token already exists and is by default projected as a volume within pods
    * Example of projected volume section within QR pod:
        ```
        volumes:
        - projected:
          sources:
          - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        ```
* simple manual recyclying
    * if a token is known to have been recently leaked, manual revocation of the kubernetes token only requires deletion of the specific pod
* enhanced vault audit granularity
    * an `alias_name_source` parameter can be configured on [vault kubernetes roles](https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#parameters-1) which will provide granularity into what entity performed a particular action


## Goals
* Utilize [vault kubernetes auth](https://developer.hashicorp.com/vault/docs/auth/kubernetes) to authenticate AppSRE applications to vault.


## Non-goals
* Identifying/configuring applications outside of AppSRE to utilize kubernetes auth


## Proposal

### Expand vault-manager to provision kubernetes auth mounts and roles
The following PRs expanded App Interface's vault config to allow reconciliation of kubernetes auth mounts and roles:
* https://github.com/app-sre/vault-manager/pull/107
* https://github.com/app-sre/qontract-schemas/pull/386
* https://github.com/app-sre/qontract-schemas/pull/384

### Grant vault SA permission to access kubernetes API server auth delegation endpoints per instance
The service account utilized for each vault instance must be assigned the `system:auth-delegator` kubernetes role.

[This MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/59516) provides an example of assigning the necessary permissions for `vault.stage.devshift.net`'s service account

#### Inter-cluster auth
The aformentioned permission will only work for authentication of applications hosted on the same cluster as the vault instance.  

In order for vault to validate kubernetes service account tokens from external clusters, the [client's JWT as reviewer JWT](https://developer.hashicorp.com/vault/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt) method will be utilized. With this method, kubernetes auth mounts can be configured for external clusters and Vault will utilize the client's supplied service account JWT to request a token review of the JWT against the api server of app's cluster. See [microservices auth using kubernetes identities](https://learnk8s.io/microservices-authentication-kubernetes) for in depth walkthrough of the interaction. In order for the client JWT method to work, the client service account must have a cluster role binding for `system:auth-delegation` (allows access to [TokenReview](https://kubernetes.io/docs/reference/kubernetes-api/authentication-resources/token-review-v1/) api resource which determines if supplied token is valid or not)

### Create vault kubernetes auth mounts
To enable a cluster to authenticate with vault, a dedicated kubernetes auth mount must be provisioned.

As an example, [this kubernetes auth definition](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/stage/auth-backends/kubernetes-appsres03ue1.yml) allows the `appsres03ue1` cluster to authenticate to `vault.stage.devshift.net`

### Create vault kubernetes roles
kubernetes-specific vault roles provide the mapping of a kubernetes service account to vault policies. Without a vault role, a k8s serviceaccount can still authenticate to the corresponding auth mount but will only be granted a token with the default policy. Therefore, a kubernetes auth role should be created for each serviceaccount utilized by AppSRE automations.

As an example, [this kubernetes role definition](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/stage/roles/kubernetes/appsres03ue1-vault-manager.yml) maps the service account utilized by vault-manager to the vault-manager policy within `vault.stage.devshift.net`

### Update AppSRE apps to utilize SA tokens for auth to vault
#### Openshift templates
Each app's openshift template should be updated to explictly [configure a bound service account token](https://docs.openshift.com/container-platform/4.12/authentication/bound-service-account-tokens.html#bound-sa-tokens-configuring_bound-service-account-tokens). Although these are being configured by default, they are using a "special value" of `3706` for the `expirationSecounds` parameter (see [stack overflow thread](https://stackoverflow.com/questions/69375195/kubernetes-projected-service-account-token-expiry-time-issue) for details). This special value equates to a one year expiration. Therefore, the projected mount should be explicitly defined within the template and set a value other than `3706`.

#### Application logic
* **vault-manager** - utilized as POC for kube auth. Required relatively large change in order to accomodate the multiple instances it is required to auth with
    * [PR enabling optional kube auth per instance](https://github.com/app-sre/vault-manager/pull/108)
* **QR** - will require update within [vault util](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/utils/vault.py#L53) to utilize sa token instead of approle creds mounted via kube secret as environment variables
    * approle logic should remain for development / jenkins pr checks
    * confirmed the service account token is already being auto-mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token` with QR pods


## Milestones
* kubernetes auth utilized by AppSRE automation within applicable stage clusters
* kubernetes auth utilized by automation within within applicable production clusters
* kubernetes auth announced as option for tenant usage
