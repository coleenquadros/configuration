# Scaling OSD Infra Nodes

There might be multiple reasons for scaling the infra nodes on an OSD cluster. One known case is if the OSD ingress router is overloaded and the CPU utilization of these nodes is too high.

SRE-P must scale the infra nodes for us. Follow the procedure below to scale the infra nodes.

1. Create an OHSS ticket in Jira to have the infra nodes on the cluster scaled up. See here for an [example ticket](https://issues.redhat.com/browse/OHSS-8695).
2. Set the priority of the ticket to **Urgent**
3. Reach out to **@sre-platform-secondary** in the **#sd-sre-platform** channel to make SRE-P aware of the ticket (making the ticket "Urgent" should also notify them)
