# Qontract-reconcile patterns

As qontract-reconcile evolves, we are finding repeating patterns in the way we write integrations. This document explains some of these patterns for reference.

## The Caller pattern

In this pattern, each instance of an integration defines a unique key for itself, which is added to the resources it applies. Another instance of the same integration is aware of it's key and before touching any resource managed by the same integration, it first checks if it's own caller matches the caller on the resource.

In case of a mismatch, the current instance skips the resource, as it is managed by another running instance.

This pattern allows us to manage resources of the same integration from different instances in the same namespace.

> Note: Comparing the caller is only done if the resource is managed by the same integration. Even if the same caller is used from different integrations, there will not be a conflict. This is how integrations can manage the same resource kind in the same namespace.

## The Wrapper pattern

In this pattern, we wrap the `run` method of an integration with a new integration called by the same name and appended with `-wrapper`.

The wrapper integration calls the integration's run method in parallel for multiple inputs with an iterable decided according to the sharding method of the called integration.

This is implemented for openshift-saas-deploy (openshift-saas-deploy-wrapper) to help us support running openshift-saas-deploy in pr-checks only for specific saas files.

A run of openshift-saas-deploy for all saas files will... never end.
