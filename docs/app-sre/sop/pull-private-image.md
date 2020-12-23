# Enable pulling private docker images in OpenShift

For a pod to be able to pull a private Docker image, it has to be running using a ServiceAccount which mounts a `kubernetes.io/dockercfg` Secret, allowing Read access to a private repository.

In the past, we used to mount such a Secret to the `default` ServiceAccount, allowing all pods to pull private images (as all pods are using the `default` ServiceAccount unless otherwise specified).

Since we can not persist the `default` ServiceAccount in app-interface, the best practice to enable pulling private images is:

1. Add a `kubernetes.io/dockercfg` secret to the namespace ([example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/68f670ce828629db7acab33f78ee31870944ff7d/data/services/uhc/namespaces/uhc-production.yml#L31-34)).
1. Add a ServiceAccount mounting this Secret to the namespace(examples [[1]](https://gitlab.cee.redhat.com/service/app-interface/-/blob/68f670ce828629db7acab33f78ee31870944ff7d/data/services/uhc/namespaces/uhc-production.yml#L73-74) [[2]](/resources/app-sre/uhc-production/clusters-service.serviceaccount.yaml#L6)).
1. Update the OpenShift tempalte to use this ServiceAccount ([example](https://gitlab.cee.redhat.com/service/uhc-clusters-service/-/blob/8b915f3fe70c08503d63639678c6008cd9122aec/service-template.yml#L272)).

Optional (not recommended for DSaaS migration):

1. For completeness, add the ServiceAccount (without the mounted Secret) to the upstream OpenShift template ([example](https://gitlab.cee.redhat.com/service/uhc-clusters-service/-/blob/8b915f3fe70c08503d63639678c6008cd9122aec/service-template.yml#L217-222)).
1. Filter out `ServiceAccount`s from being deployed from the upstream repository.
