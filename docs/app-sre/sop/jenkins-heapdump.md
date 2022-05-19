# Jenkins and heapdump

Since Jenkins runs as a java process, it is sometime useful to do heapdumps to investigate any memory related issues.
Taking a heapdump is considered a stop-the-world activity, this means any other jvm threads are paused until heapdump is complete.
Also, the pause duration during heapdump depends upon the allocated heap size and disk I/O.

## Automatic heapdump
Both ci-int and ci-ext are configured to perform heapdump automatically when JVM encounters `OutOfMemoryError`.
This is done through configuration parameters
-  `-XX:+HeapDumpOnOutOfMemoryError` which tells JVM to perform heapdump when it encounters `OutOfMemoryError`
-  `-XX:HeapDumpPath=/var/lib/jenkins/` which tells JVM the location to store the heapdump. Note, you must have enough disk space to store heapdump


## Manual heapdump

Run `sudo jmap -dump:format=b,file=/var/lib/jenkins/heapdump.hprof $(pidof java)` on jenkins controller node to perform heapdump. 



## Heapdump analysis

There are plethora of tools that can parse java heapdump, most notably Eclipse Memory Analyzer and VisualVM.
You can load heapdump into one of these tools and see object allocations. 

You can follow this guide to get more info https://dzone.com/articles/java-heap-dump-analyzer-1 

## Heapdump cleanup cron [TODO: Pending work APPSRE-5603]
