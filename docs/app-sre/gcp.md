# Google Cloud Platform (GCP)

## Informations

Red Hat has two GCP organizations:
    - gcp-internal
    - gcp-external

`gcp-internal` (org id 54643501348) uses SAML to authenticate. This means you can go to https://cloud.google.com and login with your @redhat.com email. 
- Used for internal resources, things that are used internally, not exposed to customers.

`gcp-external` uses a different authentication machanism using @gcp.redhat.com.
- Used for resouces meant for customers. (ex. OSD clusters)
- Uses @gcp.redhat.com for authentication which is granted separately.
- App-SRE currently do NOT use this

## Contacts

Jeffrey Daube (jedaube@redhat.com) helped us get started initially and is available for questions and guidance

We also pay for tech support with GCP so if we need advanced technical help. Jeffrey Daube can help us get connected to support.


## Access

Google cloud uses Projects system under which services are provisioned. It is possible to create projects at multiple levels
- No org (account level)
- Organization
- Folder (within account or orgs)

The hierarchy under which the app-sre project is current configured is:
- redhat.com (org 54643501348)
  - app-sre (folder)
    - app-sre (project)
  
At the moment, there are 3 app-sre folder admins (which means they also get admin on all projects under that folder)
- jchevret@redhat.com
- jbeakley@redhat.com
- jmelisba@redhat.com

It is possible (and recommended) to create a [Rover Group](https://rover.redhat.com/groups/) to manage access to this folder as well. Rover Groups can be set up to run a LDAP query to determine who is member of the group. The group email address can then be granted permissions on the folder. At the moment we have sd-app-sre@redhat.com but this may be a bit too wide (we add Interns to this group). If we want to set this up, Jeffrey Daube or JF Chevrette can get us started

## Manually configuring GCP & GCR for App-SRE

The following are the steps I (jfchevrette) took to set up the app-sre GCP project as well as the GCR repo.

GCR urls (or repos) are based of off the GCP project name. For instance the project `app-sre` gets the gcr repo `gcr.io/app-sre`.

**Important: Visibility (public, private) is on a per project basis (ie: gcr.io/app-sre) as the permissions are actually granted on the artifacts storage bucket. There does not appear to have a way to mix & match visibility of images within a repo.**

1) Login to Google Cloud with my @redhat.com
1) Create app-sre project under the redhat org
1) Enable Billing on corporate CC
1) Go to 'IAM Roles'
1) Create Role
    - Title: gcr-admin
    - ID: gcr_admin
    - Stage: GA
    - Add permissions:
        - storage.buckets.(create,delete,get,list,update)
        - storage.objects.(create,delete,get,list,update)
1) Create Role
    - Title: gcr-reader
    - ID: gcr_reader
    - Stage: GA
    - Add permissions:
        - storage.objects.(get,list)
1) Go to 'Service Accounts'- Login to Google Cloud with my @redhat.com
1) Create app-sre project under the redhat org
1) Enable Billing on CC
1) Go to 'IAM Roles'
1) Create Role
    - Title: gcr-admin
    - ID: gcr_admin
    - Stage: GA
    - Add permissions:
        - storage.buckets.(create,delete,get,list,update)
        - storage.objects.(create,delete,get,list,update)
1) Create Role
    - Title: gcr-reader
    - ID: gcr_reader
    - Stage: GA
    - Add permissions:
        - storage.objects.(get,list)
1) Go to 'Service Accounts'
1) Create service Account
    - Name: gcr-admin
    - Role: gcr-admin
    - Create key: JSON
10 Create service Account
    - Name: gcr-reader
    - Role: gcr-reader
    - Create key: JSON
1) Go to 'Container Registry'
1) Enable Container Registry API

# Some useful gcloud commands

## installing gcloud (versioned, ideal for cicd)

```bash
curl -sLO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-294.0.0-linux-x86_64.tar.gz
tar xzvf google-cloud-sdk-294.0.0-linux-x86_64.tar.gz
mv google-cloud-sdk $HOME
$HOME/google-cloud-sdk/install.sh -q --usage-reporting false --override-components core --path-update false
```

## Accessing GCR using gcloud ServiceAccount credentials

```
vault kv get -address=https://vault.devshift.net -format=json app-sre/creds/gcp/gcr-push | jq -r .data.token | base64 -d > keyfile.json
$HOME/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=keyfile.json
$HOME/google-cloud-sdk/bin/gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io
```
