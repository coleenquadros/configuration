# New cluster SOP
##  Requesting

What is this: Procedure to request a new openshift dedicated cluster (OSD)
Required access: email, github app-sre
Details:

- Email openshift-provisioning@redhat.com with the following information:
    - Cluster name: *eg app-sre-stage*
    - Cluster rfc1918 space: eg *10.110.0.0/16*
        - Make sure this doesn't overlap with other cluster if for VPC peering
    - Region: *eg us-east-1*
    - Compute node count: *eg 6*
        - Minimum node count for multi-az is 9, but can be agreed lower for internal customers
    - Auth setup: *eg TEAM app-sre-stage-cluster in Github org App-sre*
    - List of dedicated admins: *eg pbergene, jakedt…*

- Set up an oauth app in the relevant github org (eg app-sre)
    - Go to settings -> oauth apps -> new oauth app and supply following settings
        - Application name: *eg app-sre-stage cluster*
        - Homepage URL: *eg https://console.app-sre-stage.openshift.com/console*
        - Authorization callback URL: *eg https://api.app-sre-stage.openshift.com/oauth2callback/github*
        - Create application
    - Communicate the resulting secrets securely to SRE working the cluster provisioning

Further reading:
- 3.11 ansible provisioning variables: https://github.com/openshift/openshift-ansible-ops/blob/prod/playbooks/release/bin/template_aws_cluster_setup.yml

### Setting up vpc peering
- Note: This is a rough outline of the request - routing changes app-sre side should be managed via terraform.

- Create a snow ticket for SRE using their contact form:
    Please initiate a VPC peering connection from the backing aws account of <cluster> to the app-sre aws account

    Relevant info for peer:
    - Account ID: *eg 950916221866*
    - CIDR: *eg 192.168.0.0/20*
    - VPC ID: *eg vpc-0e9fbceea37f50cc8*
    - Region: *eg Us-east-1*

Also note that there needs to be routes added to access <app-sre CIDR> via the peering connection once completed. I will ack this peering request on the other side and set up the return routes.

- Set up return routes to <cluster CIDR>.

## App-sre setup

### Add to app-interface

- Set up saas-crypt resources for app-interface mgmt, reference other clusters for details.
    - Details found in app-interface/openshift/
- Add cluster to app-interface using vault token referenced from cluster definitions

### Add to monitoring

* TBD
