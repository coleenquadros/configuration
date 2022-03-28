ImageBuilderInternalErrors
==========================

Impact
------

Image Builder is a service which builds images. There's 2 components, image-builder-crc which
resides in consoledot and image-builder-composer which is a dependency of image-builder-crc.

If image build requests (/compose) are failing, users cannot queue new image builds. If status
requests (/composes/${id}) are failing, users cannot request the status of their images. Either mean
the core features of this service are in bad shape.

Summary
-------

This alert fires when requests have a high 500 rate.

Access required
---------------

Image-builder-crc:

- The ([Production][openshift-prod]|[Stage][openshift-stage]) Openshift cluster to view the
  image-builder-(prod|stage) namespace.
- The ([Production][kibana-prod]|[Stage][kibana-stage]) Kibana instance in order to review logs.
- The ([image-builder-crc][grafana-crc]) grafana dashboard.

Image-builder-composer:

- The ([Production][openshift-composer-prod]|[Stage][openshift-composer-stage]) Openshift cluster to
  view the composer-(production|stage) namespace.
- The ([image-builder-composer][grafana-composer]) grafana dashboard.
- The appsre log-consumer role for prod-04 & stage-01.

[openshift-stage]: https://console-openshift-console.apps.crcs02ue1.urby.p1.openshiftapps.com/
[openshift-prod]: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/
[openshift-composer-stage]: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/
[openshift-composer-prod]: https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/

[kibana-stage]: https://kibana.apps.crcs02ue1.urby.p1.openshiftapps.com/app/kibana
[kibana-prod]: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana

[grafana-crc]: https://grafana.app-sre.devshift.net/d/image-builder-crc/image-builder-crc
[grafana-composer]: https://grafana.app-sre.devshift.net/d/image-builder-composer/image-builder-composer

Steps
-----

Check the dashboards for a quick status. If the error rate is bad on both dashboards, the problem is
most likely image-builder-composer. Otherwise the problem is image-builder-crc.

### Only image-builder-crc is failing at a high rate

- Check the Kibana instances for logs, the following query can be used:
```
 @log_group:"image-builder-prod" and levelname:"error"
```
- If image-builder-crc is receiving 401s when trying to contact
  image-builder-composer, check [Red Hat status](https://status.redhat.com/) for SSO outages.
- Ping the @image-builder-team in #osbuild-image-builder-service.

### Both image-builder-composer and image-builder-crc are failing at a high rate

- Go to cloudwatch for the relevant image-builder-composer cluster.
- The following query can be used:
```
fields message
| filter (kubernetes.namespace_name = "composer-production")
| parse message "time=* level=* msg=*" as time, level, innermsg
| filter (level = "error" or level = "warning")
| display innermsg, level
| sort @timestamp desc
```
- If the jobqueue DB is full (see [rds
  dashboard](https://grafana.app-sre.devshift.net/d/AWSRDSdbi/aws-rds?var-datasource=AWS%20app-sre&var-region=default&var-dbinstanceidentifier=image-builder-composer-db-prod)),
  additional storage can be added to relieve the situation.
- Ping the @image-builder-team in #osbuild-image-builder-service.

Escalations
-----------

[Escalation policy](data/teams/image-builder/escalation-policies/image-builder.yml).
