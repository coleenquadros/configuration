# New Contract Release

The AppSRE Contract releases are GitLab releases:
https://gitlab.cee.redhat.com/app-sre/contract/-/releases

In order to create release, follow this process:

* Ensure the contract git repo is in the state you want to release.
* Create a JIRA in the APPSRE board to capture the effort. Add date to the summary. Example: [APPSRE-3364](https://issues.redhat.com/browse/APPSRE-3364).
* Create a new doc to capture the release notes. This document should include the following sections: Sections with Modifications (excluding ACs), Modified / Reworded ACs and Deleted ACs. [Example](https://docs.google.com/document/d/1MaIprCmmMi3zXDwNj94fcTgHPjQeqORYdJcQIGDxGFM/edit#heading=h.msah3ockt1kk)
* Create and push a new tag with the format vYYYY.MM.DD, example: v2021.06.15.
* That will create the release (if the pipeline succeeds). Open the new [release](https://gitlab.cee.redhat.com/app-sre/contract/-/releases), Edit it, and paste the release notes.
* Send release link to `sd-app-sre-announce@redhat.com`.
