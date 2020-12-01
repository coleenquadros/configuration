# Move ConfigMap from app-interface to upstream repository

ConfigMaps can be applied using the OpenShift template in your code repository instead of via app-interface.

To move a ConfigMap from app-interface to your code repository, follow these steps:

1. Add the ConfigMap to the OpenShift template in your code repository.
    * The template should be defined in your SaaS file, under `resourceTemplates`: `url` and `path`.
    * Do not include any sensitive information in the ConfigMap you add to your code repository. Instead, use an OpenShift template parameter.
1. Update the SaaS file and namespace file to move the ConfigMap to be deployed through the SaaS file:
    * In the namespace file, remove the `openshiftResources` items that reference a ConfigMap and remove `ConfigMap` from `managedResourceTypes`.
    * In the SaaS file, add `ConfigMap` to `managedResourceTypes` and add the parameters required to template the ConfigMap.

Example:
* https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/12565
* https://github.com/openshift/gcp-project-operator/pull/126
