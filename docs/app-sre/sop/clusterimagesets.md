# Failed clusterimageset-run job

Job: https://ci.int.devshift.net/view/app-sre/job/clusterimageset-run/

Script: https://gitlab.cee.redhat.com/service/clusterimagesets-stage/blob/master/generate-clusterimagesets.py

This jobs scrapes https://openshift-release.svc.ci.openshift.org/ in order to retrieve the list of release tags, and then uses that service's API to get JSON info for the ClusterImageSets.

If this job fails it means that the ClusterImageSets in hive-stage are not up to date. This potentially affects UHC, Hive and SRE-P teams, as the expectation is that the ClusterImageSets should be up to date in that cluster. This job should run on a daily basis as a consequence of the push that the clusterimageset-run job performs. The turnaround to solve this problem should be 1 business day, otherwise the affected teams should be informed.
