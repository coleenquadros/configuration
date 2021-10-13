# KAS Fleet Manager Release MR Template
This document outlines how the commit and merge request description should look like for new releases of KAS Fleet Manager.

## Commit message
The commit message for updating the version of KAS Fleet Manager should adhere to the following format:
```
chore: update kas-fleet-manager <prod/stage> version to <new-version>
```

## Merge request description template
```
## Manual Verification
- Verify that the dashboards in [Staging envrionment](https://grafana.stage.devshift.net/dashboards/f/zz2SVP47k/rhosak) have not been broken.

<state any manual verification steps here if required>


## Passing E2E Tests in Stage:
<link-to-report-portal-e2e-tests>

## Passing Nightly CI in Stage: 
<link-to-nightly-ci-tests>

## Changes Included:
kas-fleet-manager@<commit>...<commit> // e.g. kas-fleet-manager@e5963c0c...087b4781
```
