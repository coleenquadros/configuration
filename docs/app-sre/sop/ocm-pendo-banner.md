# Posting a maintenance / outage notification in console.redhat.com/openshift

Access to Pendo needs to be granted beforehand. It is documented in the [access list](../AAA.md#access-and-surfaces-list) of AAA.

## Publishing a banner for OCM (new or existing)

1. Nagivate to https://app.pendo.io/login and login via Google SSO & your redhat.com email

1. Navigate to `Guides`

1. In the `All Apps` dropdown, select `console.redhat.com`

1. Search for a guide that you want to publish or clone (search for "OCM" for this specific use case)

1. On the guide page, click `...` and select `Clone guide` (if this is missing, you're missing permissions). You can skip this if you want to publish a previously prepared banner.

1. If the banner message need to be changed, click on `Manage in my app` on top of the guide itself then then `Launch`. You will be asked to enter a URL and you can use https://console.redhat.com/openshift -- modify as desired, click `Save` then `Exit` to go back to Pendo. **If you do not see the pendo banner designer overlay, that usually means you have an ad blocker that is blocking pendo**.

1. If you want to schedule the banner, click `Edit` beside scheduling and select start and expiration dates as desired. (skip this if you want to post the banner right away and manually remove it when desired - this is useful for incidents for which there are typically no defined start/end)

1. Use the upper right dropdown to set the banner to `Staged` status

1. Click `Clear guide data`. This will ensure all visitors will see the banner, even is it was dismissed by visitors previously **(not applicable for new/cloned banners)**.

1. Use the upper right dropdown to set the banner to `Public` status

1. Visit https://console.redhat.com/openshift to verify that the banner is displaying properly

**Note:** We have observed some cases where the banner doesn't display with <your_username>@redhat.com, but it does on <your_username>+sd-app-sre@redhat.com - it never hurts to have a few other team members check the banner as well.

## Disable a banner

1. To remove a published banner, follow the above instructions but set the banner to `Disabled`

## Deprecated instructions

This SOP represents the most up-to-date documentation. The original instructions can be found here (if they're needed for some reason, probably not):

- https://docs.google.com/document/d/1MfCCndIH28ZX3Fq9SPCYhkmmLRiMwaPDgXCCqM0o73s/edit
- https://drive.google.com/file/d/1bzgsTo7qZRo5qvmWdKS3Ec_2ykWQNYXb/view
