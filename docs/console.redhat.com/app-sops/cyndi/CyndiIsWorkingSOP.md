# Validate Cyndi is running

### This is a simple check to validate Cyndi is sending data from the Host Inventory database into the Advisor database.

1. Upload an archive with a new tag via `insights-client --group=<some-new-group>`
1. Log into console.redhat.com
1. At the top of the page, click "Filter by status" and select the group created in the first step
1. Navigate to "Inventory" on the side nav, the list should be filtered filtered by the tag used in step 1
1. Navigate to Advisor->Recommendations, the list of recommendations should be filtered to those affecting the system uploaded in the first step.
   This will show no recommendations or a handful depending on the system used.
