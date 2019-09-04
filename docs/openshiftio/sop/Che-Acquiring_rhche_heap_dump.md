# Che - Acquiring rhche heap dump
## Required access 
* Edit access on dsaas-[preview|production]

## Performing heap dump and / or thread dump
* Log in to cluster, dsaas-[preview|production] namespace
Examples below will use namespace "dsaas-production" remember to change to "dsaas-preview" for the prod-preview cluster. 
We try to use the pod name in the rsh command via the dc reference rather than the explicit pod name here as that will always reference the "active" running pod; helpful in cases where the pod is crashing, short lived, or has replicas in varying states of birth or death.
* Get Java process PID from rhche pod
```
JPID=$(oc -n dsaas-production rsh --shell=/bin/bash --timeout=120 dc/rhche ps --no-headers -opid -C java|tr -d '\r')
```
* Perform heap dump and store in /tmp
```
[ ! -z "${JPID}" ] && oc -n dsaas-production rsh --shell=/bin/bash --timeout=120 dc/rhche jmap -dump:live,file=/tmp/rhche-heapdump.bin ${JPID}
``` 
* Perform thread dump, output locally
Change tee output path as desired (ex: rhche-threaddump.txt -> /tmp/rhche.td.out)
```
[ ! -z "${JPID}" ] && oc -n dsaas-production rsh --shell=/bin/bash --timeout=120 dc/rhche jstack ${JPID} | tee rhche-threaddump.txt
```
## Downloading heap dump
* Grab a copy of heap dump 
```
PODNAME=$(oc -n dsaas-production get pods -lapp=rhche -ojsonpath="{.items[].metadata.name}")
[ ! -z "${PODNAME}" ] && oc cp dsaas-production/${PODNAME}:/tmp/rhche-heapdump.bin .
```
* You will now have the heap and thread dumps
```
$ ls -lh rhche-heapdump.bin rhche-threaddump.txt 
-rw-r--r--. 1 mmclanerh.dsaas osobjects 164M Sep  4 12:11 rhche-heapdump.bin
-rw-r--r--. 1 mmclanerh.dsaas osobjects 194K Sep  4 11:57 rhche-threaddump.txt
```

## Transferring heap dumps
* Heap dumps are memory snapshots of the JVM instance, and may contain anything loaded to memory by the application.  This includes tokens, credentials and PII information.  This data should be transferred encrypted to individuals who nave a business need to access this data and must not be shared in plaintext or to groups via links or email.  Include the individuals the heap dump was shared with to on the request (Jira / HK) before closing.  
Example gpg cli encrypt command  
```
gpg --encrypt --sign --armor -r ibuziuk@redhat.com foo.txt
```

* Thread dumps contain memory references, they are to be kept internal on Red Hat equipment, but do not require encryption. Always review what you are distributing.  

# Additional notes
This is an ad hoc solution pending prioritization from Che development teams to participate in implementing a automated solution, as agreed with Ilya Buziuk the 14th of June 2019. This will be raised to Che PMs by engineering.
