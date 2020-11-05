# Posting a maintenance / outage notification in cloud.redhat.com/openshift

Access to Pendo needs to be granted beforehand. It is documented in the [access list](../AAA.md#access-and-surfaces-list) of AAA.

This document is the most up-to-date. The original instructions can be found here:
- https://docs.google.com/document/d/1MfCCndIH28ZX3Fq9SPCYhkmmLRiMwaPDgXCCqM0o73s/edit
- https://drive.google.com/file/d/1bzgsTo7qZRo5qvmWdKS3Ec_2ykWQNYXb/view

## Publishing a banner for OCM (new or existing)

1. Nagivate to https://app.pendo.io/login and login via Google SSO & your redhat.com email

1. Navigate to `Guides`

1. In the `All Apps` dropdown, select `cloud.redhat.com`

1. Search for a guide that you want to publish or clone

1. On the guide page, click `...` and select `Clone guide` (skip this if you want to publish an previously prepared banner)

1. If the banner message need to be changed, click on `Manage in my app` on top of the guide itself then then `Launch`. This will take you to a special URL on cloud.redhat.com where you will be able to change the banner and see it as it would appear. Modify as desired, click `Save` then `Exit` to go back to Pendo. **If you do not see the pendo banner designer overlay, that usually means you have an ad blocker that is blocking pendo**

1. If you want to schedule the banner, click `Edit` beside scheduling and select start and expiration dates as desired. (skip this if you want to post the banner right away and manually remove it when desired - this is useful for incidents for which there are typically no defined start/end)

1. Use the upper right dropdown to set the banner to `Staged` status

1. Click `Clear guide data`. This will ensure all visitors will see the banner, even is it was dismissed by visitors previously. (not applicable for new/cloned banners)

1. Use the upper right dropdown to set the banner to `Public` status

1. That's it.

## Disable a banner

1. To remove a published banner, follow the above instructions but set the banner to `Disabled`
