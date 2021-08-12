# Detach a Pod from a Controller

## Background

Kubernetes controllers (Deployments, StatefulSets, etc) know which pods are associated with them based upon labels.  The controller has a definition for a label selector, and the pods in the pod spec also have those same labels.  When the pod is created, it will have the labels that match the controller's label selector, and that will allow the controller to know about the pod.

There is also an OwnerReference on the pod that tells kubernetes components what owns the pod (ie Deployment, StatefulSet, etc).  For a pod created by a controller this information will typically be set to match the object which caused the creation of the pod.

## Purpose

This SOP will provide a means to detach a pod from its owner object so that it can be debugged/inspected without concern of being replaced or removed should the parent owner object change.  This means that after the steps in the SOP are complete, the pod will not be attached to the owner object anymore which will cause the controller to spin up another pod.  This needs to be considered carefully because it will mean 2 pods that are doing the same thing.

## Steps

1. Find the pod to detach from the controller
1. Edit the pod's metadata and remove:
  1. All the labels
  1. The ownerReference for the owning object.  This will look like:

    ```yaml
    ownerReferences:
      - apiVersion: batch/v1
        kind: <Kind>
        name: <controller name>
        uid: 93310623-f892-4ad3-813a-302f2454375f
        controller: true
        blockOwnerDeletion: true
    ```
1. Save the changes to the pod's metadata.

The pod is now detached from the owning object, which means it won't be affected by changes to the owner object that created it.  It also means the controller will immediately spin up a new pod to replace it.

*NOTE*: This pod will *NOT* be cleaned up like other pods that are controlled by their owner objects.  This means when work is done on the detached pod it will need to be deleted *manually*.

