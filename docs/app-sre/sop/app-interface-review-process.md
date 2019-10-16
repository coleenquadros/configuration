# App Interface review process

This is a WIP SOP intended for use by App SRE team members acting as Interrupt Catcher or just reviewing merge requests to app-interface.

## Process

1. Verify that build passes.
2. Verify that the `app-interface JSON validation` report is as expected due to the changes introduced in the MR.
3. If any additional reviewers are required, ping them on the MR (see #additional-reviewers).
4. Once the MR looks good to you, add the `lgtm` label. The MR will be merged automatically within minutes.

## Notes

* Some merge requests will be created with an `automerge` label. No need to review or merge those.

## Additional Reviewers

Telemeter access:
```
@kasingh @ccoleman @cvogel
```

Insights cluster access:
```
@klape @gavin @bturner
```

Datahub PSI dashboards:
```
@ccoleman
```
