# Che - Acquiring rhche heap dump
## Required access 
* Edit access on dsaas-[preview|production]

## Performing heap dump and / or thread dump
* Log in to cluster, dsaas-[preview|production] namespace
* Get rhche pods
```
oc get pods -lapp=rhche
```
* oc rsh into rhche pods returned by previous command
```
oc rsh <rhche-pod-identifier>
```
* Get PID of java process
```
pgrep -l java
```
* Perform heap dump and store in /tmp
```
jmap -dump:live,file=/tmp/rhche-heapdump.bin <java pid>
``` 
* Perform thread dump 
```
jstack <java pid> > /tmp/rhche-threaddump.txt
```
## Downloading / distributing heap dump
* Grab a copy of heap dump 
```
oc cp <rhche-pod-identifier>:/tmp/rhche-heapdump.bin .
```
* Grab a copy of thread dump
```
oc cp <rhche-pod-identifier>:/tmp/rhche-threaddump.txt .
```

## Transferring heap dumps
* Heap dumps are memory snapshots of the JVM instance, and may contain anything loaded to memory by the application.  This includes tokens, credentials and PII information.  This data should be transferred encrypted to individuals who nave a business need to access this data and must not be shared in plaintext or to groups via links or email.  Include the individuals the heap dump was shared with to on the request (Jira / HK) before closing.

* Thread dumps contain memory references, they are to be kept internal on Red Hat equipment, but do not require encryption. Always review what you are distributing.  

# Additional notes
This is an ad hoc solution pending prioritization from Che development teams to participate in implementing a automated solution, as agreed with Ilya Buziuk the 14th of June 2019. This will be raised to Che PMs by engineering.
