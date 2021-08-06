ImageBuilderNoPodsUp
=============

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Image Builder is a service used to build images. It acts as an interface for composer.

Summary
-------

This alert fires when no pods are up.

Access required
---------------

-  Access to the `(Production|Stage) Openshift cluster`_ to view the image-builder-(prod|stage) namespace.
-  Access to the `Kibana instance`_ in order to review logs.

Steps
-----

-  Check logs / events for pods in the image-builder-(prod|stage) namespace
-  Check where the errors are occuring, either in Image Builder or in the Composer
   service it depends on.

Escalations
-----------

-  Ping the engineering team who own the app (#osbuild on CoreOS Slack), preferably with any logs or data that you were able to gather.
