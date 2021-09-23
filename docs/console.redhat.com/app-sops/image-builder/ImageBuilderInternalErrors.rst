ImageBuilderInternalErrors
==========================

Severity: Info
--------------

Impact
------

-  Image Builder is a service used to build images. It acts as an interface for composer.

Summary
-------

This alert fires when the compose request, the request to build an image, errors
out too much.

Access required
---------------

-  Access to the (Production|Stage) Openshift cluster to view the image-builder-(prod|stage) namespace.
-  Access to the Kibana instance in order to review logs.
-  Access to the (Production|Stage) Grafana instance to see the current failure rate on the dashboard.

Steps
-----

-  Check the dashboard for a quick status.
-  Check logs / events for pods in the image-builder-(prod|stage) namespace.
-  Check where the errors are occuring, either in Image Builder or in the Composer
   service it depends on.

Escalations
-----------

See https://visual-app-interface.devshift.net/services#/services/insights/image-builder/app.yml
