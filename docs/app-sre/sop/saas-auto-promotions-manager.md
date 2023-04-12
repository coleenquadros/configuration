# saas-auto-promotions-manager (SAPM)

SAPM is responsible for managing auto-promotion MRs.

## Turning off SAPM

### Via unleash feature flag

The easiest way is to disable the whole integration via the [unleash feature toggle](https://app-interface.unleash.devshift.net/projects/default/features/saas-auto-promotions-manager).

### Disabling MR management

You can also keep SAPM running, but prevent it from doing any MR management.

You can prevent SAPM from opening new MRs via [this feature toggle](https://app-interface.unleash.devshift.net/projects/default/features/saas-auto-promotions-manager-allow-opening-mrs)

Further, you can tell SAPM to stop closing "bad" MRs with [this feature toggle](https://app-interface.unleash.devshift.net/projects/default/features/saas-auto-promotions-manager-allow-deleting-mrs)
