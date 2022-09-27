# Continuity document

## Impact of data loss

Data loss may result in

* customers won't see their clusters in advisor
* no recommendations or not updated recommendations
* customers won't see alerts about critical/important issues with their clusters
* RH support may be impacted as well
* RH teams working with our data are not able generate any cluster statistics

## backup policy

The data pipeline often works with very recent or real time data; and is continuously 
producing new data. Our disaster recovery strategy must take those characteristics
into account: rolling back our databases to a previous state is not always the best 
solution as there's the concrete risk of losing more recent and newly created data.
Hence the actions required to recover from a disaster need a case-to-case discussion.

Nonetheless the service does implement a back-up policy, our database are defined in
[app-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ccx-data-pipeline/namespaces/ccx-data-pipeline-prod.yml) 
Look for `ccx-data-pipeline-db` and `ccx-notification-db`, they both point to this
[database definition](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/insights/production/rds/postgres11-rds-1.yml)

We don't do any backups beyond what RDS provides (see [link](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html)).
In case the decision of restoring a database snapshot has been made, we'd follow [this procedure with terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#restore_to_point_in_time).

Moreover it is possible to control when the last back-up was performed by following
[this link](https://prometheus.app-sre-prod-01.devshift.net/)
and perform this query: 

```
time() - aws_resources_exporter_rds_latestrestorabletime{dbinstance_identifier=~"ccx-.*"}
```



