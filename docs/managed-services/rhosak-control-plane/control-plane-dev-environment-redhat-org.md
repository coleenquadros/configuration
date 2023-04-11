# Control Plane team development environment's Red Hat organization

The Managed Kafka Control Plane team has its own Red Hat Organization that
team members can use for development purposes of the control plane.

Each team member in the Managed Kafka Control Plane
team needs to be provisioned a Red Hat User belonging to that Red Hat
organization.

This Red Hat Organization is also commonly known as the Managed Kafka
Control Plane team development environment organization.

This Red Hat Organization is an organization in the Red Hat External SSO Production
environment (https://sso.redhat.com/) and it uses the `redhat-external` OIDC
realm. The Red Hat Organization ID for this organization is `16737056`.
This organization is not to be confused with the commonly known as "Kafka Service"
Red Hat organization which is used at RHOSAK level and also by Control Plane
team members to interact with the OpenShift Cluster Managemer (OCM) service.

## User creation

Organization administrators of the Managed Kafka Control Plane team development
environment organization can create new Red Hat SSO Users in the organization.

If you are not an organization administrator ask that some organization
administrator in the control plane team creates it for you.

To create a user, an organization administrator can access the
[User Management console of the Red Hat organization](https://www.redhat.com/wapps/ugc/protected/usermgt/userList.html)
in the Red Hat Customer Portal.

Then a user can be created by selecting `Add new user`.

In the next screen the user details can be filled.
If the User to be created is for a new control plane team member
the following conventions are defined:
* Red Hat Login (this is the User name): `<redhat_kerberos_username>_dev_mk_control_plane`.
  For example, for a team member whose Red Hat Kerberos username is `msoriano`
  the Red Hat Login value to be set would be: `msoriano_dev_mk_control_plane`
* Email: `<redhat_mail_address_local_part>+dev_mk_control_plane@redhat.com`. For
  example, for a team member whose Red Hat mail address is `msoriano@redhat.com`
  the Email value to be set would be: `msoriano+dev_mk_control_plane@redhat.com`

As part of the User creation process several permissions can be selected. One
of the permissions is making the user an Administrator of the organization.
Organization administrator permissions grant permissions to manage the Organization's
Users and control their access and permissions so it should be assigned
with caution.

Once all the details and permissions are set press `Save` to complete the
User creation. A mail will be sent to the associated Email for that user, prompting
him to confirm its new login and to create a password. That information including
the password should be saved and kept safe by the team member that received the
mail.

**_NOTE:_** Due to the way Single Sign-On works it is possible that the user's
            web browser still has a SSO session with another user. Make sure to
            tell the user that it should press the confirmation link in a
            new session, to avoid any issues with a potentially active
            previous SSO session.

## Service accounts

Red Hat SSO Service accounts compatible to be used for Red Hat Application
Services like for example RHOSAK can be created.

A Service Account is an OIDC Service Account of the Client Credentials grant
type.

There is a limit of maximum number of Service Accounts for a given Red Hat
organization. That limit is at Red Hat organization level and not at User level.
At the moment of writing this (2023-04-11) the maximum number of Service Accounts
in a Red Hat organization is 50.

Service Accounts can be created for the Managed Kafka Control Plane team
development environment organization.

All members of a Red Hat organization can see all the Service Accounts created
in it, even those created by other Users in that organization.

### Service account creation

Any User of the Managed Kafka Control Plane team
development environment organization can create Service Accounts for that
organization, even if the User is not an organization administrator.

To create a Service Account, go to the [Red Hat Cloud Console](https://console.redhat.com/)
and login with your User in the Managed Kafka Control Plane team development
environment organization.

Once logged in, go to the [Application Services Service Accounts console](https://console.redhat.com/application-services/service-accounts)
and press the `Create Service Account` button.

In the next screen the Service Account details can be filled.
If the Service Account to be created is for a new control plane team member the
following conventions are defined:
* Description: `<redhat_kerberos_username>-dev-mk-control-plane-sa`. For example,
  for a team member whose Red Hat	Kerberos username is `msoriano` the Service Account
  description to be set would be: `msoriano-dev-mk-control-plane-sa`

Once the details are filled and submitted the Client ID and Client Secret
associated to that Service Account are shown. Save and store them safely as
they will only be showed this time. If you need to pass the Client ID and
Client Secret to some other team member make sure to send it in a safe way.

The created Service Accounts themselves have permissions to create other
Service Accounts for the organization.

A common usage of a Service Account is to configure KAS Fleet Manager
to use a Client ID and Client Secret used to create the Service Accounts
for the Data Planes.
