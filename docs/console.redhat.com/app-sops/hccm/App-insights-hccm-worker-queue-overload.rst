App-insights-hccm-worker-queue-overload
=======================================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCCM worker queues have experienced a high backlog over the last hour. This could cause a lag in customer data processing.

Summary
-------

This alert fires when the HCCM worker queues have had more than 1000 tasks in the queues in the past hour.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)
-  Turnpike access to cost-management internal apis (for db-performance endpoints)
    -  Direct databae access to the cost-management-prod database (if connection action is required)

Steps
-----

-  Log into the console / namespace and verify if worker pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check the internal endpoint for blocking locks in the database. (See specific documentation below)
-  Check recent PR for changes made to the celery workers.
-  Scaling the workers should improve report processing throughput if its not a bug.
-  Notify service owners if changes have occurred in the above

Database Lock Contention
------------------------

1.  Access the internal endpoint for a live query for lock contention information from the database. (https://internal.console.redhat.com/api/cost-management/v1/db-performance/lock-info/)
2.  The result will be a HTML page with a table of result information.
    a.  If there are no locks you will see "No blocking locks"
    b.  If there are blocking locks, you will see the following data:
        -  Action : Buttons that will display SQL to be executed if action is needed to cancel or terminate a connection.
        -  blocking_pid : The backend connection pid that is blocking other connections
        -  blocking_user : The user of the blocking connection
        -  blocked_pid : The backend connection pid that is being blocked
        -  blocked_user : The user of the blocked connection
        -  blocked_statement : The SQL statement that is being blocked.
        -  blckng_proc_curr_stmt : The current active statement or the last statement executed in the blocking connection

The desired state is "No blocking locks". However a small number of locks may simply be part of the data processing via multiple connections. To verify, wait a minute or two, then refresh the page. If the locks grow or do not change, then escalate to the development team.

If, however, there are many rows of lock records, then action may need to be taken. Be aware that locks can cascade: Connecton A can block connection B and connection B can block connection C, etc. Check to see if the queues are growing by navigating to https://internal.console.redhat.com/api/cost-management/v1/celery_queue_lengths/ and refreshing that page a few times to check if the queue lengths are increasing.

If the root lock can be determine the root lock (the top-level lock from which all other lock cascade), then the connection's activity can be cancelled. This may be a faster solution than scaling worker pods down and up. Click the "Show SQL for Cancel blocking_pid" button to display the SQL to execute in psql or gabi. Execute the sql and reload the page. If this worked, then the lock contention should resolve itself quickly and will be reflected via lock info page reload.

If the locks do not change or get worse, then scale workers down to zero, then back to the prior replicas.

Search for a ticket in the COST MANAGEMENT Jira project for "LOCK CONTENTION: PRODUCTION". If no open ticket exists, please create one and set it as a BUG. On the new or found ticket, enter the alert information and number of locks found and the top-level lock's SQL information. Also add a link to the alert information. Finally add any action that has been taken by AppSRE. Then ping the #cost-mgmt-sre channel with the ticket.

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
