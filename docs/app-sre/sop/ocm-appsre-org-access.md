# OCM App-SRE org onboarding

This document explains how to manage App-SRE team members in the App-SRE OCM organization.

We use a special email address pattern rather than the user's regular company email as it often already exists in the system and we are unable to grant the correct permissions.

The email address pattern to use is [<ldap_user>+sd-app-sre@redhat.com]() (basically, add `+sd-app-sre` to your company email)

## Add a new user

**Note:** Using an incognito browser window is recommended to avoid conflicts with existing sessions in OCM, SSO, RedHat customer portal

1. Login to https://cloud.redhat.com/

1. Click the [cogwheel](https://console.redhat.com/settings/) in the top right

1. Go to [Users](https://console.redhat.com/settings/rbac/users)

1. Click [User management list](https://www.redhat.com/wapps/ugc/protected/usermgt/userList.html)

1. Click the **Invite User** link

1. Fill the invite user form

    - Email: [<ldap_user>+sd-app-sre@redhat.com]()
    - Permissions: Organization **administrator**

1. Click "Invite New Users"

1. Once the invite is accepted by the user, they should see the App-SRE clusters listed at https://console.redhat.com/openshift/
