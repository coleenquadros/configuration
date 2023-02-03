# Edge Performance Tests

## Load Testing

The Performance & Scale Team has tested and updated plans for ongoing testing.

The perf environment is configured in app-interface with the [Edge Management application](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/insights/edge).

Tests are run via the [InsightsEdge_runner Jenkins Pipeline](https://master-jenkins-csb-perf.apps.ocp-c1.prod.psi.redhat.com/view/Insights_CPT/job/InsightsEdge_runner/). Please contact the Perf & Scale team for more information on access to running Jenkins jobs in the Perf environment.

## Prerequisites

To be able to run the performance test, you need to become a member of [perf-team-jenkins-engineers Rover group](https://rover.redhat.com/groups/group/perf-team-jenkins-engineers). Ping group owners to be added (i.e. jhutar, kdelee and psuriset). Another way would be just asking somebody who is already the member of the group to run the test for you.

## Run the Tests

Once you are a member of that `perf-team-jenkins-engineers` group, login to [Jenkins](https://master-jenkins-csb-perf.apps.ocp-c1.prod.psi.redhat.com/) and build the [InsightsEdge_runner job](https://master-jenkins-csb-perf.apps.ocp-c1.prod.psi.redhat.com/view/Insights_CPT/job/InsightsEdge_runner/). It will run the test against image tag that is deployed in the Perf cluster now.

## Tweak the Performance Deployment

Edge deployment in Perf cluster can be tweaked in the [Edge deploy config](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/edge/deploy.yml). Look for `perf-edge-perf` namespace. Please let rajchauh and jhutar know before changing something here.

## Deploy Fresh Image Tags

If you need to deploy some fresh image tags before running the test, build the [InsightsEdge_builder job](https://master-jenkins-csb-perf.apps.ocp-c1.prod.psi.redhat.com/view/Insights_CPT/job/InsightsEdge_builder/) that deploys last image from quay.io and builds `InsightsEdge_runner`. Normally, `InsightsEdge_builder` runs every hour so it is possible it already ran for the image tag you are interested in.

## View the Results

To review the results, go to the [CPT Dashboard](http://kibana.intlab.perf-infra.lab.eng.rdu2.redhat.com/app/dashboards#/view/ac0477e0-3fc3-11ed-bceb-dd413e7b6847). I assume you will be interested in RHCloud CPT: Edge device ingestion: Average device ingestion duration graph the most. You should also review details on how the test works in "RHCloud CPT: Edge device ingestion: test description" box and graphs about CPU and memory consumption.

# More Information

For more information on test process and results, see [RHEL Edge perf&scale notes](https://docs.google.com/document/d/1VMg_TC-ican_NDrg4cfpbeohgtYKKhFD7r0sSyqeck8/edit%23heading%3Dh.muehff6ryz4&sa=D&source=docs&ust=1670796512789632&usg=AOvVaw2DktfkeLaHtuyhg0On9hXZ)
