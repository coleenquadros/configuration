NodeOvercommittedMemory
==============

Severity: Medium
--------------

Impact
------

Nodes are put into an unstable state due to OOMKiller being invoked outside a
contianer's cgroup.  While we haven't seen the OOMKiller kill the kubelet or
container runtime, this is always a possibility, which would likely lead to the
node being put into an unstable state.

Summary
-------

An overcommited node in this instance means that the combined memory limits of
all the pods deployed on a given node exceed the allocatable memory of that
node.  We fire an alert when the combined limits exceed 110% of the allocatable
memory of any given node.

Access required
---------------

Need dedicated-admin to the target cluster to view all events and node info.

Steps
-----

Open up the console link in the alert.  There should be a red dot in the middle
column with the text "This node’s memory resources are overcommitted. The total
memory resource limit of all pods exceeds the node’s total capacity. Pods will
be terminated under high load."  Then click the "see breakdown" to open a
tooltip that will give you the top consumers.  Use this information to find out
which pods are taking up the most memory on this node.

Pods/deployments can been in violation in a couple of ways:

1. Very high limit.  There are some valid use cases for this, but it can be
   used as a band aid for poor memory management or a memory leak.  If that is
   the case, app teams need to address the problem with priority.
2. High limit:request ratio.  An example would be a request of 1Gi and a limit
   of 10Gi.  This is always a bad practice and should be fixed as soon as
   possible.  As a general rule any ratio where the limit is more than 2x the
   request should be adjusted.

Escalations
-----------

- Ping @platform-dev-prod or @crc-escalation Slack handles.
- Ping the engineering team that owns the apps
