# Qontract-reconcile patterns

As qontract-reconcile evolves, we are finding repeating patterns in the way we write integrations. This document explains some of these patterns for reference.

## The Caller pattern

In this pattern, each instance of an integration defines a unique key for itself, which is added to the resources it applies. Another instance of the same integration is aware of it's key and before touching any resource managed by the same integration, it first checks if it's own caller matches the caller on the resource.

In case of a mismatch, the current instance skips the resource, as it is managed by another running instance.

This pattern allows us to manage resources of the same integration from different instances in the same namespace.

> Note: Comparing the caller is only done if the resource is managed by the same integration. Even if the same caller is used from different integrations, there will not be a conflict. This is how integrations can manage the same resource kind in the same namespace.

## The Delete pattern

In this pattern, we handle the deletion of resources that are not kept in any sort of state.

Most of our integrations are stateless, and compare the desired state against the current state to understand what actions should be carried out to fulfill the desired state. The current state depends on the integration, and can be OpenShift resources, Jenkins jobs, Vault secret engines, etc.

In all these cases, if a resource is deleted from app-interface, it is still found in the "current state" and can be deleted.

There are cases when removing a resource from app-interface means that we lose knowledge of it and can not delete it. This is where the Delete pattern comes into play.

By adding (and implementing) a `delete: true` section to any resource, we still keep track of it in our desired state, while at the same time we understand that it should be deleted. After the resource was deleted, it should be safe to remove the entire deleted section from app-interface.

## The Provider pattern

In this pattern, we allow defining items in a similar way while handling them differently behind the scenes.

For example, to apply OpenShift resources to a namespace (via a namespace file), we allow defining resources under `openshiftResources` with a `provider` key, indicating if the resource:
- comes from Vault (vault-secret)
- comes from the resources directory (resource)
- comes from the resources directory and includes templating (resource-template)

Each item is handled a bit differently in our integrations, while allowing users to define all resources in a similar way or even in a single location.

## The Wrapper pattern

In this pattern, we wrap the `run` method of an integration with a new integration called by the same name and appended with `-wrapper`.

The wrapper integration calls the integration's run method in parallel for multiple inputs with an iterable decided according to the sharding method of the called integration.

This is implemented for openshift-saas-deploy (openshift-saas-deploy-wrapper) to help us support running openshift-saas-deploy in pr-checks only for specific saas files.

A run of openshift-saas-deploy for all saas files will... never end.
