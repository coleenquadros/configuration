# diag-container

## Overview

The `diag-container` is a container that contains all the tooling required by AppSRE, and it will be used in many SOPs. An example for this is running manual SQL queries against vpc peered RDS instances.

Repository: https://github.com/app-sre/diag-container

## Creating it

- Make sure the `app-sre` namespace exists.
- `oc process --local -f https://raw.githubusercontent.com/app-sre/diag-container/master/openshift.yml | oc apply -n app-sre -f -`
